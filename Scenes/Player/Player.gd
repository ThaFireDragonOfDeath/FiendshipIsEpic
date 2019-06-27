extends Node2D

signal destroyed(player_obj)

var player_vel = Vector2(0, 0) # Player velocity vector
export var player_speed = 800 # Player move speed
export var player_slow_speed = 400 # Player move speed on slow mode

var screen_size: Vector2 = Vector2(0, 0)
var clamp_offset: Vector2 = Vector2(55, 55)

export(String, "Chrysalis", "Sombra", "Tirek") var character = "Chrysalis"
export(int, 1, 3) var player_number = 1
export(int, 1, 3) var player_health = 1
export(int, 0, 1000) var player_energy = 100
export(int) var player_energy_max = 1000
export(bool) var alive = true

# Helper variables for shooting
var shoot_time_limit = 0.5
var shoot_lvl_up_wait_time = 1.0
var can_shoot = true
var shoot_fired = false
var current_shot_lvl = 0
var shoot_key_pressed = false
var shoot_key_once_pressed = false
var shoot_diagonal_up = false
var shoot_diagonal_down = false

var character_node = null
var global_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	character_node = get_node(character)
	global_node = get_node("/root/GlobalDataStorage")
	
	# Set up selected character
	clamp_offset = character_node.clamp_offset
	shoot_time_limit = character_node.shoot_time_limit
	$PlayerInput.player_number = player_number
	
	# Set player y position
	var current_player_count = get_node("/root/GlobalDataStorage").player_count
	character_node.position.y = screen_size.y / (current_player_count + 1) * player_number
	
	character_node.visible = true
	character_node.monitoring = true
	character_node.monitorable = true
	
	add_to_group("players")
	global_node.current_players_alive.push_back(self)
	
	# Play flying animation
	character_node.get_node("AnimatedSprite").play()
	
	# Set up timers
	$ShootReload.wait_time = shoot_time_limit
	
	$PlayerInput.enable_input = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move the character
	move_character(delta)

# Called every physics frame. 'delta' is the elapsed time since the previous physics frame.
func _physics_process(delta):
	if alive:
		# Process user input
		get_input()
		
		# Process shooting logic
		if can_shoot && player_energy >= 2:
			process_shoot()
		
		# Emit shots
		if shoot_fired:
			emit_shoot()
			shoot_fired = false
			can_shoot = false
			current_shot_lvl = 0
			$ShootReload.start()

func _on_ShootReload_timeout():
	can_shoot = true

func get_input():
	var current_player_speed = player_speed
	
	# Reset velocity vector
	player_vel = Vector2(0, 0)
	
	# React to left, right up, down
	if is_action_pressed("left"):
		player_vel.x -= 1
	if is_action_pressed("right"):
		player_vel.x += 1
	if is_action_pressed("up"):
		player_vel.y -= 1
	if is_action_pressed("down"):
		player_vel.y += 1
	
	# React on slow down
	if is_action_pressed("slow"):
		current_player_speed = player_slow_speed
	
	if is_action_pressed("shoot") || is_action_pressed("shoot_diagonal_up") || is_action_pressed("shoot_diagonal_down"):
		shoot_key_pressed = true
	else:
		shoot_key_pressed = false
	
	if is_action_pressed("shoot_diagonal_up"):
		shoot_diagonal_up = true
	if is_action_pressed("shoot_diagonal_down"):
		shoot_diagonal_down = true
	
	# Calculate velocity vector
	if player_vel.length() > 0:
		player_vel = player_vel.normalized() * current_player_speed

func is_action_pressed(action):
	return $PlayerInput.pressed_actions.has(action)

func move_character(delta):
	character_node.position += player_vel * delta
	character_node.position.x = clamp(get_node(character).position.x, clamp_offset.x, screen_size.x - clamp_offset.x)
	character_node.position.y = clamp(get_node(character).position.y, clamp_offset.y, screen_size.y - clamp_offset.y)
	get_node("LvlUp").position = character_node.position + character_node.weapon_offset
	
	global_node.set("current_player" + String(player_number) + "_pos",get_node(character).position)

func emit_shoot():
	var weapon_name = "ChrysalisBeam"
	var weapon_offset = get_node(character).weapon_offset
	var weapon_rows = 1
	var shoot_angle = 0
	var shoot_angle_min = 0
	var shoot_angle_max = 0
	var fast_shoot_count = 1
	var fast_shoot_delay = 0.08
	var shoot_speed_boost = 0
	
	# Set shoot angle
	if shoot_diagonal_up:
		shoot_angle = 40
	elif shoot_diagonal_down:
		shoot_angle = -40
	
	# Reset shoot diagonal pressed variable
	shoot_diagonal_up = false
	shoot_diagonal_down = false
	
	if current_shot_lvl == 0:
		player_energy -= 2
		
		if character == "Chrysalis":
			weapon_name = "ChrysalisBeam"
		elif character == "Sombra":
			weapon_name = "SombraCrystal"
			weapon_rows = 2
		elif character == "Tirek":
			weapon_name = "TirekBlast"
	elif current_shot_lvl == 1:
		player_energy -= 100
		current_shot_lvl = 0
		
		if character == "Chrysalis":
			weapon_name = "ChrysalisBeam"
			shoot_angle_min = -3
			shoot_angle_max = 3
			fast_shoot_count = 15
			shoot_speed_boost = 100
		elif character == "Sombra":
			weapon_name = "SombraCrystal"
			weapon_rows = 4
			fast_shoot_count = 12
			fast_shoot_delay = 0.2
		elif character == "Tirek":
			weapon_name = "TirekBlast"
			shoot_angle_min = -5
			shoot_angle_max = 5
			fast_shoot_count = 20
			shoot_speed_boost = 100
		
		var weapon_scene = preload("res://Scenes/Weapon/Weapon.tscn")
		var weapon_node = weapon_scene.instance()
		weapon_node.position = get_node(character).position
		weapon_node.weapon_name = "GenericExplosion"
		weapon_node.explosion_animation = "Lvl1Explosion"
		add_child(weapon_node)
	
	var weapon_scene = preload("res://Scenes/Weapon/Weapon.tscn")
	
	if character == "Sombra" && weapon_rows == 2:
		var weapon_node_1 = weapon_scene.instance()
		var weapon_node_2 = weapon_scene.instance()
		var delay = (float(1) / float(get_node(character).shoot_speed)) * (float(get_node(character).delay_px_offset))
		
		weapon_node_1.position = get_node(character).position + weapon_offset
		weapon_node_2.position = get_node(character).position + weapon_offset
		weapon_node_1.position.y -= 12
		weapon_node_2.position.y += 12
		weapon_node_2.delay = delay
		
		weapon_node_1.weapon_name = weapon_name
		weapon_node_1.shoot_speed = get_node(character).shoot_speed + shoot_speed_boost
		weapon_node_1.shoot_angle = shoot_angle
		weapon_node_2.weapon_name = weapon_name
		weapon_node_2.shoot_speed = get_node(character).shoot_speed + shoot_speed_boost
		weapon_node_2.shoot_angle = shoot_angle
		
		add_child(weapon_node_1)
		add_child(weapon_node_2)
	else:
		for i in range(0, fast_shoot_count):
			for j in range(0, weapon_rows):
				var weapon_node = weapon_scene.instance()
				weapon_node.position = get_node(character).position + weapon_offset
				
				if weapon_rows % 2 == 0:
					weapon_node.position.y += (12 * weapon_rows * j) - (float(12 * weapon_rows) / 2.0 / 2.0)
				else:
					weapon_node.position.y += (12 * weapon_rows * j) - ((12 * weapon_rows) / 2)
				
				if shoot_angle_min != 0 || shoot_angle_max != 0:
					shoot_angle = rand_range(shoot_angle_min, shoot_angle_max)
				
				weapon_node.weapon_name = weapon_name
				weapon_node.shoot_speed = get_node(character).shoot_speed + shoot_speed_boost
				weapon_node.shoot_angle = shoot_angle
				weapon_node.delay = i * fast_shoot_delay
				weapon_node.sync_bullet_position = true
				add_child(weapon_node)

func process_shoot():
	if shoot_key_pressed:
		if shoot_key_once_pressed != true:
			$ShootLvlUp.start(shoot_lvl_up_wait_time)
			shoot_key_once_pressed = true
	else:
		if shoot_key_once_pressed == true:
			shoot_key_once_pressed = false
			$ShootLvlUp.stop()
			shoot_fired = true

func _on_ShootLvlUp_timeout():
	# TODO: Shoot lvl up sound
	
	if player_energy >= 100:
		current_shot_lvl += 1
		get_node("AnimationPlayer").play("LvlUp")
	
	if current_shot_lvl >= 1:
		$ShootLvlUp.stop()

func _on_Player_area_entered(area):
	var is_weapon = get_tree().get_nodes_in_group("weapons").has(area.get_parent())
	
	if is_weapon && area.get_parent().weapon_team == "Enemy":
		if player_health <= 1 && alive == true:
			area.get_parent().despawn()
			despawn()
		else:
			get_node("HitSound").play()
			player_health -= 1
			area.get_parent().despawn()

func _on_SelfDelete_timeout():
	call_deferred("queue_free")

func increase_energy():
	player_energy += 15
	
	if player_energy > player_energy_max:
		player_energy = player_energy_max

func despawn():
	alive = false
	
	character_node.set_deferred("monitoring", false)
	character_node.set_deferred("monitorable", false)
	
	get_node("AnimationPlayer").stop(true)
	get_node("AnimationPlayer").get_animation("PlayerDespawn").track_set_path(0, character + ":modulate")
	get_node("AnimationPlayer").play("PlayerDespawn")
	
	call_deferred("remove_from_group", "players")
	global_node.current_players_alive.erase(self)
	emit_signal("destroyed")
	
	var weapon_scene = preload("res://Scenes/Weapon/Weapon.tscn")
	var weapon_node = weapon_scene.instance()
	weapon_node.position = get_node(character).position
	weapon_node.weapon_name = "GenericExplosion"
	weapon_node.explosion_animation = "Lvl1Explosion"
	call_deferred("add_child", weapon_node)
	get_node("SelfDelete").start()

func _on_AutoEnergy_timeout():
	if player_energy < 100:
		player_energy += 10
		
		if player_energy > 100:
			player_energy = 100

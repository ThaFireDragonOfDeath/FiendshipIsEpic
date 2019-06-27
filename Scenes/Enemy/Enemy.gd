extends Node2D

signal destroyed(enemy_obj)

export(String, "Centaur", "Gargoyle", "Scorpan") var character = "Centaur"

export(String, "Fixed", "Random") var movement_mode = "Fixed"
export(String, "Static", "R2L", "Sync2World") var x_movement = "Static"
export(String, "Static", "UpAndDown") var y_movement = "Static"
export(String, "Fixed", "Random", "Rotate") var shoot_time_mode = "Fixed"
export(float, 0.1, 20.0) var shoot_time = 0.5
export(float, 0.1, 20.0) var shoot_time_min = 0.1
export(float, 0.1, 20.0) var shoot_time_max = 2.0
export(String, "Fixed", "Random", "Rotate") var shoot_seq_mode = "Fixed"
export(String, "Std", "StdPlayerDirection", "StdRandomDirection", "FastSeq") var shoot_sequence = "Std"
export(Vector2) var enemy_start_pos = Vector2(1800, 550)

var enemy_vel = Vector2(0, 0) # Enemy velocity vector
export var enemy_speed = 210 # Enemy move speed
export(int, 1, 9000) var enemy_health = 1

var screen_size
var clamp_offset: Vector2 = Vector2(55, 70)
var alive = true

# Chances for random movements
var chances_x_movement = [100]
var chances_y_movement = [100]

# Chances for shoot sequences
var chances_shoot_seq = [100]

# Available elements
var available_x_movements = ["Static"]
var available_y_movements = ["Static"]
var available_shoot_seqs = ["Std"]

# Other shoot parameters
var fast_seq_time_offset = 0.2
var fast_seq_bullet_count = 10

var shoot_angle_min = -8
var shoot_angle_max = 8

# Internal move values
var current_y_move_direction = "Up"
var y_move_speed = 300

# Other internal values
var first_shoot_fired = false
var character_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	character_node = get_node(character)
	
	#Set start position
	character_node.position.x = screen_size.x + 180
	character_node.position.y = enemy_start_pos.y
	
	if character == "Centaur":
		character_node.position.y = screen_size.y - 100
	
	# Get parameters from selected character
	chances_x_movement = character_node.chances_x_movement
	chances_y_movement = character_node.chances_y_movement
	chances_shoot_seq = character_node.chances_shoot_seq
	
	available_x_movements = character_node.available_x_movements
	available_y_movements = character_node.available_y_movements
	available_shoot_seqs = character_node.available_shoot_seqs
	
	fast_seq_time_offset = character_node.fast_seq_time_offset
	fast_seq_bullet_count = character_node.fast_seq_bullet_count
	
	shoot_angle_min = character_node.min_shoot_angle
	shoot_angle_max = character_node.max_shoot_angle
	
	init_movement()
	init_shoot()
	
	character_node.visible = true
	character_node.monitoring = true
	character_node.monitorable = true
	character_node.get_node("AnimatedSprite").play()
	
	add_to_group("enemies")
	
	if x_movement == "Static":
		var current_enemy_pos = character_node.position
		var animation = Animation.new()
		animation.set_length(1.5)
		animation.set_loop(false)
		animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(0, character + ":position")
		animation.track_insert_key(0, 0, current_enemy_pos)
		animation.track_insert_key(0, 1, Vector2(enemy_start_pos.x, current_enemy_pos.y))
		$AnimationPlayer.add_animation("MoveIn", animation)
		$AnimationPlayer.play("MoveIn")

func _physics_process(delta):
	if alive == true:
		var movement_vec = Vector2(get_x_movement(delta), get_y_movement(delta))
		character_node.position += movement_vec

func emit_shoot():
	var current_players_alive = get_node("/root/GlobalDataStorage").current_players_alive
	var current_players_alive_count = current_players_alive.size()
	
	if current_players_alive_count != 0 && alive == true:
		var weapon_name = get_weapon_name(character)
		var weapon_scene = preload("res://Scenes/Weapon/Weapon.tscn")
		var weapon_node = weapon_scene.instance()
		
		weapon_node.weapon_team = "Enemy"
		weapon_node.weapon_name = weapon_name
		weapon_node.shoot_direction = "left"
		weapon_node.position = character_node.position
		
		if shoot_seq_mode == "Rotate":
			var shoot_sequence_idx = get_random_element_nr(chances_shoot_seq)
			shoot_sequence = available_shoot_seqs[shoot_sequence_idx]
		
		if shoot_time_mode == "Rotate":
			shoot_time = rand_range(shoot_time_min, shoot_time_max)
		
		if shoot_sequence == "Std":
			add_child(weapon_node)
		elif shoot_sequence == "StdPlayerDirection":
			var player_count = get_node("/root/GlobalDataStorage").current_players_alive.size()
			var target_player = randi() % player_count + 1
			var target_player_number = get_node("/root/GlobalDataStorage").current_players_alive[target_player - 1].player_number
			var player_pos = get_node("/root/GlobalDataStorage").get("current_player" + String(target_player_number) + "_pos")
			var weapon_pos = weapon_node.position
			
			var angle_rad = weapon_pos.angle_to_point(player_pos)
			weapon_node.shoot_angle = rad2deg(angle_rad) * -1
			
			add_child(weapon_node)
		elif shoot_sequence == "StdRandomDirection":
			var random_angle = rand_range(shoot_angle_min, shoot_angle_max)
			weapon_node.shoot_angle = random_angle
			add_child(weapon_node)
		elif shoot_sequence == "FastSeq":
			for i in range(0, fast_seq_bullet_count):
				var shoot_angle = 0
				weapon_node = weapon_scene.instance()
				weapon_node.weapon_team = "Enemy"
				weapon_node.weapon_name = weapon_name
				weapon_node.shoot_direction = "left"
				weapon_node.position = character_node.position
				
				if shoot_angle_min != 0 || shoot_angle_max != 0:
					shoot_angle = rand_range(shoot_angle_min, shoot_angle_max)
				
				weapon_node.shoot_angle = shoot_angle
				weapon_node.delay = i * fast_seq_time_offset
				weapon_node.sync_bullet_position = true
				
				add_child(weapon_node)

func get_random_element_nr(chances):
	var random_nr = (randi() % 100) + 1 # Get random number from 1 to 100
	var current_sum = 0
	
	for x in range(0, chances.size()):
		var current_chance = chances[x]
		
		if current_sum + current_chance >= random_nr:
			return x
		else:
			current_sum += current_chance
	
	return 0

func get_weapon_name(character, weapon_number = 1):
	if character == "Centaur":
		return "TirekBlast"
	elif character == "Gargoyle" || character == "Scorpan":
		return "ScorpanSpear"

func init_movement():
	if movement_mode != "Fixed":
		var x_movement_idx = get_random_element_nr(chances_x_movement)
		x_movement = available_x_movements[x_movement_idx]
		
		var y_movement_idx = get_random_element_nr(chances_y_movement)
		y_movement = available_y_movements[y_movement_idx]

func init_shoot():
	# Get next shoot sequence
	if shoot_seq_mode != "Fixed":
		var shoot_sequence_idx = get_random_element_nr(chances_shoot_seq)
		shoot_sequence = available_shoot_seqs[shoot_sequence_idx]
	
	# Get next shoot time
	if shoot_time_mode != "Fixed":
		shoot_time = rand_range(shoot_time_min, shoot_time_max)
	
	$NextShoot.start(shoot_time)
	first_shoot_fired = true

func get_x_movement(delta):
	if x_movement == "Static":
		return 0
	elif x_movement == "R2L":
		var x_move_direction = -1
		var current_x_move = x_move_direction * enemy_speed * delta
		return current_x_move
	elif x_movement == "Sync2World":
		var x_move_direction = -1
		var world_speed = get_node("/root/GlobalDataStorage").current_world_movement_speed
		var current_x_move = x_move_direction * world_speed * delta
		return current_x_move

func get_y_movement(delta):
	if y_movement == "Static":
		return 0
	elif y_movement == "UpAndDown":
		var y_move_direction = -1
		#current_y_move_direction = "Up"
		var current_y_pos = character_node.position.y
		
		if current_y_move_direction == "Up":
			y_move_direction = -1
			
			if current_y_pos <= clamp_offset.y:
				current_y_move_direction = "Down"
		else:
			y_move_direction = 1
			
			if current_y_pos >= screen_size.y - clamp_offset.y:
				current_y_move_direction = "Up"
		
		var current_y_move = y_move_direction * y_move_speed * delta
		return current_y_move

func _on_Enemy_area_entered(area):
	var is_weapon = get_tree().get_nodes_in_group("weapons").has(area.get_parent())
	
	if is_weapon && area.get_parent().weapon_team == "Player" && alive == true:
		enemy_health -= area.get_parent().damage
		
		if enemy_health < 1:
			area.get_parent().shooter_obj.get_parent().increase_energy()
			get_node("/root/GlobalDataStorage").current_enemys_shoot += 1
			despawn()
		
		if area.get_parent().weapon_name != "GenericExplosion":
			area.get_parent().despawn()

func _on_Enemy_screen_exited():
	despawn()

func _on_NextShoot_timeout():
	emit_shoot()
	
	if shoot_sequence == "FastSeq" && first_shoot_fired == true:
		$NextShoot.start(shoot_time + 3)
	else:
		$NextShoot.start(shoot_time)

func despawn():
	character_node.set_deferred("visible", false)
	character_node.set_deferred("monitoring", false)
	character_node.set_deferred("monitorable", false)
	
	alive = false
	
	call_deferred("remove_from_group", "enemies")
	get_node("EnemyRemove").start()

func _on_EnemyRemove_timeout():
	call_deferred("quere_free")
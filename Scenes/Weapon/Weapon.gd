extends Node2D

export(String, "Player", "Enemy") var weapon_team = "Player" # Is the shot fired from a player or an enemy
export(String, "ChrysalisBeam", "SombraCrystal", "ScorpanSpear", "GenericExplosion") var weapon_name = "ChrysalisBeam"
export(String, "left", "right") var shoot_direction = "right"
export(int, -90, 90) var shoot_angle = 0
export(int) var shoot_speed = 1500
export(String, "PlayerDeath") var explosion_animation = "PlayerDeath"
export(int) var delay = 0
export(bool) var sync_bullet_position = false
export(int, 0, 20) var damage_boost = 0

var screen_size
var shoot_vec = Vector2(0, 0)
var shoot_active = false
var shooter_obj
var shooter_pos_at_spawn

var weapon_sound = ""
var damage = 0
var volume_db = 0

var weapon_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	weapon_node = get_node(weapon_name)
	add_to_group("weapons")
	
	screen_size = get_viewport_rect().size
	damage = weapon_node.std_damage
	volume_db = weapon_node.volume_db
	
	var x_direction = 1
	var y_direction = -1 * sin(deg2rad(shoot_angle)) 
	
	if shoot_direction == "left":
		x_direction = -1
	
	y_direction *= x_direction
	weapon_node.scale.x *= x_direction
	shoot_vec = Vector2(x_direction, y_direction)
	weapon_node.rotation_degrees = shoot_angle * -1
	weapon_sound = weapon_node.weapon_sound
	shooter_obj = get_parent().get("character_node")
	
	if sync_bullet_position == true && shooter_obj != null:
		shooter_pos_at_spawn = shooter_obj.position
	
	if delay == 0:
		_on_Delay_timeout()
	else:
		$Delay.wait_time = delay
		$Delay.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if shoot_active:
		var weapon_node = get_node(weapon_name)
		
		if weapon_node != null && weapon_name != "GenericExplosion":
			weapon_node.position += shoot_vec * shoot_speed * delta

func _on_VisibilityNotifier2D_screen_exited():
	despawn()

func _on_Delay_timeout():
	if shooter_obj == null || shooter_obj.get_parent().alive == true || weapon_name == "GenericExplosion":
		if sync_bullet_position == true && shooter_obj != null:
			var current_shooter_pos = shooter_obj.position
			var shooter_pos_diff = shooter_pos_at_spawn - current_shooter_pos
			get_node(weapon_name).position -= shooter_pos_diff
		
		get_node(weapon_name).visible = true
		get_node(weapon_name).monitoring = true
		get_node(weapon_name).monitorable = true
		shoot_active = true
		
		# Play default animation
		get_node(weapon_name + "/AnimatedSprite").play()
		
		if weapon_name == "GenericExplosion":
			get_node("GenericExplosion/AnimationPlayer").connect("animation_finished", self, "_on_GenericExplosion_finished")
			get_node("GenericExplosion/AnimationPlayer").play(explosion_animation)
		
		# Play weapon sound
		var audio_stream = load("res://Audio/Sound/" + weapon_sound)
		audio_stream.format = AudioStreamSample.LOOP_DISABLED
		$WeaponSound.stream = audio_stream
		$WeaponSound.volume_db = volume_db
		$WeaponSound.play()

func _on_GenericExplosion_area_entered(area):
	var is_weapon = get_tree().get_nodes_in_group("weapons").has(area.get_parent())
	
	if is_weapon && area.get_parent().weapon_team == "Enemy" && area.get_parent().weapon_name != "GenericExplosion":
		area.get_parent().despawn()

func _on_GenericExplosion_finished(animation_name):
	despawn()

func despawn():
	weapon_node.set_deferred("visible", false)
	weapon_node.set_deferred("monitoring", false)
	weapon_node.set_deferred("monitorable", false)
	
	shoot_active = false
	
	call_deferred("remove_from_group", "weapons")
	$SelfRemove.start()

func _on_SelfRemove_timeout():
	call_deferred("queue_free")

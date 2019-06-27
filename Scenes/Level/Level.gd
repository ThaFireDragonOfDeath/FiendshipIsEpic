extends Node2D

signal level_completed(level_number, lvl_success)

var world_movement_speed = 420
export(int, 0, 900) var ground_height = 20
export(int, 1, 5) var difficulty = 1
export(int) var level_nr = 1
export(float, 0.2, 5.0) var enemy_cycle_min = 1
export(float, 0.2, 5.0) var enemy_cycle_max = 3
export(int, 0, 100) var enemy_spawn_chance = 65

export(String) var bg_music = "Level-01.wav"
export(String) var bg_boss_music = "Level-01-Boss.wav"

var available_enemys = ["Centaur", "Gargoyle"]
var enemy_chances = [30, 70]
var available_bosses = ["Scorpan"]

var current_enemy_cycle_min
var current_enemy_cycle_max

var dialog_content_1 = ["Tirek", "Finaly, after over thousend years", "", "", -1]
var dialog_content_2 = ["Scorpan", "Ti. Tirek? What are you doing here?", "", "", -1]
var dialog_content_3 = ["Tirek", "What do you think?", "", "", -1]
var dialog_content_4 = ["Tirek", "I want revenge! Because of you, I was locked up in tatarus for more then thousend years.", "", "", -1]
var dialog_content_5 = ["Scorpan", "I wished it hadn't needed come so far, but you left me no choise.", "", "", -1]
var dialog_content_6 = ["Scorpan", "To warn the princess was the only option to save the ponys from you.", "", "", -1]
var dialog_content_7 = ["Scorpan", "But mayby we can let the past be the past and make a new beginning. You are still my broth", "", "", -1]
var dialog_content_8 = ["Tirek", "I HAVE NO BROTHER ANYMORE!", "", "", -1]
var dialog_content_9 = ["Tirek", "You lionface don't know how it feels to be betrayed from his own brother and be imprisioned for such a long time.", "", "", -1]
var dialog_content_10 = ["Tirek", "And the worst thing is. You didn't even visited me. We can never be friends and now it's time for you pay", "", "", -1]

var boss_node = null
var lvl_success = false

var player_nodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("/root/GlobalDataStorage").current_world_movement_speed = world_movement_speed
	get_node("/root/GlobalDataStorage").current_ground_height = ground_height
	get_node("/root/GlobalDataStorage").current_enemys_shoot = 0
	get_node("/root/GlobalDataStorage").player_invulnerable = false
	
	$ParallaxBackground/ParallaxLayer.motion_mirroring = $ParallaxBackground/ParallaxLayer/Background.texture.get_size()
	
	var player_count = get_node("/root/GlobalDataStorage").player_count
	var current_player_scene = preload("res://Scenes/Player/Player.tscn")
	var game_difficulty = get_node("/root/GlobalDataStorage").game_difficulty
	var init_player_health = 1
	
	if game_difficulty == "Hard":
		init_player_health += 4
	elif game_difficulty == "Hopeless":
		init_player_health += 2
	
	for i in range(1, player_count + 1):
		var current_player_node = current_player_scene.instance()
		var current_player_character = get_node("/root/GlobalDataStorage").get("player" + String(i) + "_selected_character")
		
		current_player_node.character = current_player_character
		current_player_node.player_number = i
		current_player_node.player_health = init_player_health
		var signal_bindings = [current_player_node]
		current_player_node.connect("destroyed", self, "_on_Player_destroyed", signal_bindings)
		
		# Init life and energy label
		get_node("LblPlayer" + String(i)).visible = true
		get_node("LblHPlayer" + String(i)).visible = true
		get_node("LblHPlayer" + String(i)).text = String(init_player_health)
		get_node("LblEPlayer" + String(i)).visible = true
		get_node("LblEPlayer" + String(i)).text = String(current_player_node.player_energy)
		
		player_nodes.push_back(current_player_node)
		add_child(current_player_node)
	
	current_enemy_cycle_min = enemy_cycle_min
	current_enemy_cycle_max = enemy_cycle_max
	
	var audio_stream = load("res://Audio/Music/" + bg_music)
	$BgMusic.stream = audio_stream
	$BgMusic.play()
	
	get_node("AnimationPlayer").play("FadeIn")
	$EnemyCycle.start(2)
	get_node("DiffUp").start()
	
	#spawn_enemy_debug()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Work around to sync the parallaxlayer modulate with the level modulate
	$ParallaxBackground/ParallaxLayer.modulate = modulate
	
	var direction_vec = Vector2(1, 0)
	var move_vec = direction_vec * delta * world_movement_speed
	
	$ParallaxBackground.scroll_offset -= move_vec

func _physics_process(delta):
	var player_count = get_node("/root/GlobalDataStorage").player_count
	
	for i in range(1, player_count + 1):
		var current_player_health = 0
		var current_player_energy = 0
		
		if player_nodes[i - 1] != null:
			current_player_health = player_nodes[i - 1].player_health
			current_player_energy = player_nodes[i - 1].player_energy
		
		get_node("LblHPlayer" + String(i)).text = String(current_player_health)
		get_node("LblEPlayer" + String(i)).text = String(current_player_energy)
	
	if boss_node != null:
		$LblHBoss.text = String(boss_node.enemy_health)

func rearm_EnemyCycle():
	var random_time = rand_range(enemy_cycle_min, enemy_cycle_max)
	$EnemyCycle.start(random_time)

func _on_EnemyCycle_timeout():
	var random_number = randi() % 100 # Range: 0 - 99
	
	if random_number < enemy_spawn_chance:
		spawn_enemy()
	
	rearm_EnemyCycle()

func get_random_element_nr(chances):
	var random_nr = randi() % 100 + 1 # Get random number from 1 to 100
	var current_sum = 0
	
	for x in range(0, chances.size()):
		var current_chance = chances[x]
		
		if current_sum + current_chance >= random_nr:
			return x
		else:
			current_sum += current_chance
	
	return 0

func change_difficulty(new_difficulty):
	enemy_cycle_min -= 0.05
	enemy_cycle_max -= 0.1
	enemy_spawn_chance += 4
	
	if new_difficulty == 5:
		get_node("DiffUp").stop()
		display_boss_dialog()
	
	difficulty = new_difficulty
	#print(difficulty)

func display_boss_dialog():
	var i = 1
	var current_dialog_content = get("dialog_content_" + String(i))
	while current_dialog_content != null:
		$BossDialog.add_dialog_entry(current_dialog_content[0], current_dialog_content[1], current_dialog_content[2], current_dialog_content[3], current_dialog_content[4])
		i += 1
		current_dialog_content = get("dialog_content_" + String(i))
	
	get_node("BossDialog").pause_mode = Node.PAUSE_MODE_PROCESS
	
	$BossDialog.activate_dialog()
	$BossDialog.visible = true
	
	get_tree().paused = true

func _on_DiffUp_timeout():
	var current_enemys_shoot = GlobalDataStorage.current_enemys_shoot
	if current_enemys_shoot >= 10 * difficulty:
		change_difficulty(difficulty + 1)

func _on_BossDialog_dialog_finished():
	get_node("BossDialog").pause_mode = Node.PAUSE_MODE_INHERIT
	
	var audio_stream = load("res://Audio/Music/" + bg_boss_music)
	$BgMusic.stream = audio_stream
	
	get_tree().paused = false
	
	var enemy_scene = preload("res://Scenes/Enemy/Enemy.tscn")
	var enemy_node = enemy_scene.instance()
	enemy_node.character = "Scorpan"
	enemy_node.movement_mode = "Fixed"
	enemy_node.shoot_time_mode = "Rotate"
	enemy_node.shoot_time_max = 1.5
	enemy_node.x_movement = "Static"
	enemy_node.y_movement = "UpAndDown"
	enemy_node.shoot_seq_mode = "Rotate"
	enemy_node.enemy_health = 50
	
	var signal_bindings = [enemy_node]
	enemy_node.connect("destroyed", self, "_on_Boss_destroyed")
	
	add_child(enemy_node)
	
	$LblBoss.visible = true
	$LblHBoss.visible = true
	boss_node = enemy_node
	$BgMusic.play()

func _on_Boss_destroyed(enemy_node):
	boss_node = null
	GlobalDataStorage.player_invulnerable = true
	lvl_success = true
	get_node("EnemyCycle").stop()
	get_node("DiffUp").stop()
	get_node("LvlEnd").start(2)

func _on_LvlEnd_timeout():
	get_node("AnimationPlayer").play("FadeOut")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "FadeOut":
		emit_signal("level_completed", level_nr, lvl_success)

func spawn_enemy():
	var enemy_to_spawn_idx = get_random_element_nr(enemy_chances)
	var enemy_to_spawn_str = available_enemys[enemy_to_spawn_idx]
	
	var enemy_scene = preload("res://Scenes/Enemy/Enemy.tscn")
	var enemy_node = enemy_scene.instance()
	var random_y_pos = int(rand_range(200, 800))
	var init_pos = Vector2(enemy_node.enemy_start_pos.x, random_y_pos)
	enemy_node.character = enemy_to_spawn_str
	enemy_node.movement_mode = "Random"
	enemy_node.shoot_time_mode = "Random"
	enemy_node.shoot_seq_mode = "Random"
	enemy_node.enemy_start_pos = init_pos
	add_child(enemy_node)

func spawn_enemy_debug():
	var enemy_scene = preload("res://Scenes/Enemy/Enemy.tscn")
	var enemy_node = enemy_scene.instance()
	var random_y_pos = int(rand_range(200, 800))
	var init_pos = Vector2(enemy_node.enemy_start_pos.x, random_y_pos)
	enemy_node.character = "Gargoyle"
	
	enemy_node.movement_mode = "Fixed"
	enemy_node.shoot_time_mode = "Random"
	#enemy_node.shoot_seq_mode = "Random"
	
	#enemy_node.movement_mode = "Fixed"
	enemy_node.x_movement = "Static"
	enemy_node.y_movement = "Static"
	#enemy_node.shoot_time_mode = "Random"
	enemy_node.shoot_seq_mode = "Fixed"
	enemy_node.shoot_sequence = "FastSeq"
	#enemy_node.enemy_start_pos = init_pos
	add_child(enemy_node)

func _on_Player_destroyed(player_obj):
	var player_number = player_obj.player_number
	player_nodes[player_number - 1] = null
	
	var players_alive_count = GlobalDataStorage.current_players_alive.size()
	
	if players_alive_count == 0:
		get_node("EnemyCycle").stop()
		get_node("DiffUp").stop()
		get_node("LvlEnd").start(2)

func _on_btnContinue_pressed():
	pass # Replace with function body.

func _on_btnRetry_pressed():
	pass # Replace with function body.

func _on_btnQuit_pressed():
	emit_signal("level_completed", level_nr, lvl_success)

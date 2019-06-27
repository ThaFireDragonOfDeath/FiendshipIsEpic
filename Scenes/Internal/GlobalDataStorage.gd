extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Control settings
export(String, "Keyboard", "Gamepad") var player1_input_method = "Keyboard"
export(String, "Keyboard", "Gamepad") var player2_input_method = "Gamepad"
export(String, "Keyboard", "Gamepad") var player3_input_method = "Gamepad"

export(int, -1, 9) var player1_gamepad_nr = -1
export(int, -1, 9) var player2_gamepad_nr = 0
export(int, -1, 9) var player3_gamepad_nr = 1

# Game settings
export(String, "Hard", "Hopeless", "Nightmare") var game_difficulty = "Hard"
export(int, 1, 3) var player_count = 1
export(String, "Chrysalis", "Sombra", "Tirek") var player1_selected_character = "Chrysalis"
export(String, "Chrysalis", "Sombra", "Tirek") var player2_selected_character = "Sombra"
export(String, "Chrysalis", "Sombra", "Tirek") var player3_selected_character = "Tirek"

# Live values
export(int) var current_world_movement_speed = 420
export(int) var current_ground_height = 0
export(Vector2) var current_player1_pos
export(Vector2) var current_player2_pos
export(Vector2) var current_player3_pos
export(int, 0) var current_enemys_shoot = 0
export(bool) var player_invulnerable = false
export(Array) var current_players_alive = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

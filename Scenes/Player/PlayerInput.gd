extends Node2D

# Current input states
var available_actions = ["left", "right", "up", "down", "slow", "shoot", "shoot_diagonal_up", "shoot_diagonal_down"]
var pressed_actions = []
var player_number = 1
var enable_input = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if enable_input:
		var input_source = ""
		var input_device = -1
		
		if event.is_class("InputEventJoypadButton") || event.is_class("InputEventJoypadMotion"):
			input_source = "Gamepad"
			input_device = event.device
		elif event.is_class("InputEventKey"):
			input_source = "Keyboard"
			input_device = -1
		
		var current_player_input_source = get_node("/root/GlobalDataStorage").get("player" + String(player_number) + "_input_method")
		var current_player_input_device = get_node("/root/GlobalDataStorage").get("player" + String(player_number) + "_gamepad_nr")
		
		if input_source == current_player_input_source && input_device == current_player_input_device:
			for action in available_actions:
				if event.is_action_pressed(action):
					if !pressed_actions.has(action):
						pressed_actions.push_back(action)
					
					get_tree().set_input_as_handled()
				elif event.is_action_released(action):
					while pressed_actions.has(action):
						pressed_actions.erase(action)
					
					get_tree().set_input_as_handled()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

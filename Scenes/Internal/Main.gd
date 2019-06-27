extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var current_plattform = OS.get_name()
	if current_plattform == "X11":
		var file = File.new()
		file.open("res://Joystick/linux-dinput-remap.txt", File.READ)
		var remap_txt = file.get_as_text()
		var remap_str = ""
		
		var connected_joypads = Input.get_connected_joypads()
		for jp in connected_joypads:
			var current_jp_guid = Input.get_joy_guid(jp)
			remap_str += current_jp_guid + ",," + remap_txt
		
		Input.add_joy_mapping(remap_str, true)

func _on_MainMenu_game_started():
	$MainMenu.visible = false
	$MainMenu/BgMusic.stop()
	var lvl_scene = preload("res://Scenes/Level/Level.tscn")
	var lvl_node = lvl_scene.instance()
	var signal_bindings = [lvl_node]
	lvl_node.connect("level_completed", self, "_on_Level_completed", signal_bindings)
	add_child(lvl_node)

func _on_Level_completed(level_number, lvl_success, lvl_node):
	lvl_node.call_deferred("queue_free")
	
	if lvl_success == false:
		$MainMenu.visible = true
		$MainMenu/pnStart/btnStStart.grab_focus()
		$MainMenu/BgMusic.play()
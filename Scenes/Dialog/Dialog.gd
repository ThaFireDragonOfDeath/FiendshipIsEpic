extends Node2D

signal dialog_finished()

var character_list = []
var text_list = []
var background_list = [] # "" = use background from previus entry; "default" = no background
var music_list = [] # "" = use music from previus entry; "default" = no music
var ane_wait_time_list = [] # Auto switch to next szene after defined time

var current_active_entry = -1
var current_loaded_entry = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	activate_dialog()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_accept") && current_loaded_entry >= 0:
		if $pnText/DText.text != text_list[current_loaded_entry]:
			$pnText/DText.text = text_list[current_loaded_entry]
		else:
			current_active_entry += 1
			
			if current_active_entry < character_list.size():
				load_entry(current_active_entry)
			else: 
				emit_signal("dialog_finished")
				reset()
				call_deferred("queue_free")

func activate_dialog():
	if character_list.size() >= 1 && text_list.size() >= 1:
		current_active_entry = 0
		load_entry(current_active_entry)

func add_dialog_entry(character = "Chrysalis", text = "", background = "", music = "", ane_wait_time: float = -1):
	character_list.push_back(character)
	text_list.push_back(text)
	background_list.push_back(background)
	music_list.push_back(music)
	ane_wait_time_list.push_back(ane_wait_time)

func load_entry(entry_nr):
	var character = character_list[entry_nr]
	var text = text_list[entry_nr]
	var background = background_list[entry_nr]
	var music = music_list[entry_nr]
	var ane_wait_time = ane_wait_time_list[entry_nr]
	
	current_loaded_entry = entry_nr
	
	if background != "":
		$DBG.play(background)
	
	if music != "":
		if music == "default":
			$BackgroundMusic.stop()
		else:
			$BackgroundMusic.stream = load("res://Audio/Music/" + music)
			$BackgroundMusic.play()
	
	if character != "" && text != "":
		$DPic.texture = load("res://Characters/" + character + "/Sprites/Dialog/Dialog.0000.png")
		$pnText/DText.text = ""
		$pnText.visible = true
		$NextLetter.start()
	else:
		$pnText.visible = false
	
	if ane_wait_time > 0.0:
		$NextEntry.start(ane_wait_time)

func reset():
	current_active_entry = -1
	current_loaded_entry = -1
	character_list = []
	text_list = []
	background_list = []
	ane_wait_time_list = []
	
	$DBG.play("default")

func _on_NextLetter_timeout():
	if current_loaded_entry >= 0 && text_list[current_loaded_entry] != "" && character_list[current_loaded_entry] != "":
		var already_printed_letters = $pnText/DText.text.length()
		var letter_to_print = text_list[current_loaded_entry].substr(already_printed_letters, 1)
		$pnText/DText.text = $pnText/DText.text + letter_to_print
		$LetterSound.play()
		
		# Stop timer if the full text is on screen
		if $pnText/DText.text == text_list[current_loaded_entry]:
			$NextLetter.stop()

func _on_NextEntry_timeout():
	current_active_entry += 1
	load_entry(current_active_entry)

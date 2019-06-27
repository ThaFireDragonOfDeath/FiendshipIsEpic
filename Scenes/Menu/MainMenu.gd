extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_gp_to_set = 0

# Options
var player1_gamepad_nr = -1
var player2_gamepad_nr = 0
var player3_gamepad_nr = 1

# Signals
signal game_started()

# Called when the node enters the scene tree for the first time.
func _ready():
	$pnLeft/btnStart.grab_focus()
	
	# Add option items
	$pnOptions/obCtlPlayer1.add_item("Keyboard", 0)
	$pnOptions/obCtlPlayer1.add_item("Gamepad", 1)
	
	# Player 2 and 3 can only be played with a gamepad at this time
	$pnOptions/obCtlPlayer2.add_item("Gamepad", 1)
	$pnOptions/obCtlPlayer3.add_item("Gamepad", 1)
	
	# Select std values
	if $pnOptions/obCtlPlayer1.selected == -1:
		$pnOptions/obCtlPlayer1.selected = 0
	
	$pnOptions/obCtlPlayer2.selected = 0
	$pnOptions/obCtlPlayer3.selected = 0
	
	# Add start items
	$pnStart/obDifficulty.add_item("Hard", 0)
	$pnStart/obDifficulty.add_item("Hopeless", 1)
	$pnStart/obDifficulty.add_item("Nightmare", 2)
	
	if $pnStart/obDifficulty.selected == -1:
		$pnStart/obDifficulty.selected = 0
	
	$pnStart/obPlayerCount.add_item("1 Player", 0)
	$pnStart/obPlayerCount.add_item("2 Players", 1)
	$pnStart/obPlayerCount.add_item("3 Players", 2)
	
	if $pnStart/obPlayerCount.selected == -1:
		$pnStart/obPlayerCount.selected = 0
	
	$pnStart/obChSlPl1.add_item("Chrysalis", 0)
	$pnStart/obChSlPl1.add_item("Sombra", 1)
	$pnStart/obChSlPl1.add_item("Tirek", 2)
	
	if $pnStart/obChSlPl1.selected == -1:
		$pnStart/obChSlPl1.selected = 0
	
	$pnStart/obChSlPl2.add_item("Chrysalis", 0)
	$pnStart/obChSlPl2.add_item("Sombra", 1)
	$pnStart/obChSlPl2.add_item("Tirek", 2)
	
	if $pnStart/obChSlPl2.selected == -1:
		$pnStart/obChSlPl2.selected = 1
	
	$pnStart/obChSlPl3.add_item("Chrysalis", 0)
	$pnStart/obChSlPl3.add_item("Sombra", 1)
	$pnStart/obChSlPl3.add_item("Tirek", 2)
	
	if $pnStart/obChSlPl3.selected == -1:
		$pnStart/obChSlPl3.selected = 2
	
	checkPlayerSelection()
	
	$Background.play()
	
	# Ready up option values
	for i in range(1,4):
		var selected_item = get_node("pnOptions/obCtlPlayer" + String(i)).get_selected_id()
		var btn_node = get_node("pnOptions/btnScPl" + String(i))
		
		if selected_item == 1:
			btn_node.disabled = false
		else:
			btn_node.disabled = true
	

func _input(event):
	if player_gp_to_set >= 1 && player_gp_to_set <= 3:
		if event.is_class("InputEventJoypadButton"):
			var gamepadNumber = event.device
			set("player" + String(player_gp_to_set) + "_gamepad_nr", gamepadNumber)
			$PopupDialog.hide()
			get_node("pnOptions/btnScPl" + String(player_gp_to_set)).grab_focus()
			player_gp_to_set = 0
		elif event.is_class("InputEventKey") && event.scancode == KEY_ESCAPE:
			$PopupDialog.hide()
			get_node("pnOptions/btnScPl" + String(player_gp_to_set)).grab_focus()
			player_gp_to_set = 0
		
		get_tree().set_input_as_handled()

# Check that one character is selected by only one player
func checkPlayerSelection(plKeep: int = 0):
	var uncheckedPlayers = [1, 2, 3]
	var unusedChars = [0, 1, 2]
	
	# First process the player, which selection is fixed and shall not be edited
	if plKeep <= 3 && plKeep >= 1:
		var selectedChar = get_node("pnStart/obChSlPl" + String(plKeep)).selected
		var itemPos = unusedChars.find(selectedChar)
		unusedChars.remove(itemPos)
		uncheckedPlayers.remove(plKeep - 1)
	
	# Iterate over every player selection and give him another character, if the
	# character is already taken
	for player in uncheckedPlayers:
		var selectedChar = get_node("pnStart/obChSlPl" + String(player)).selected
		
		if selectedChar != -1:
			var findPos = unusedChars.find(selectedChar)
			
			if findPos == -1:
				get_node("pnStart/obChSlPl" + String(player)).selected = unusedChars[0]
				unusedChars.remove(0)
			else:
				unusedChars.remove(findPos)

func _on_btnQuit_pressed():
	get_tree().quit()

func _on_btnOptions_pressed():
	$pnStart.visible = false
	$pnOptions.visible = true
	$pnOptions/btnOpOk.grab_focus()

func _on_btnStart_pressed():
	$pnOptions.visible = false
	$pnStart.visible = true
	$pnStart/btnStStart.grab_focus()

func _on_btnStBack_pressed():
	$pnStart.visible = false
	$pnLeft/btnStart.grab_focus()

func _on_btnScPl_pressed(player_number):
	player_gp_to_set = player_number
	$PopupDialog.popup()

func _on_obCtlPlayer_item_selected(ID, player_number):
	if ID == 0:
		get_node("pnOptions/btnScPl" + String(player_number)).disabled = true
	elif ID == 1:
		get_node("pnOptions/btnScPl" + String(player_number)).disabled = false
		if player1_gamepad_nr == -1:
			player1_gamepad_nr = 0
			player2_gamepad_nr = 1
			player3_gamepad_nr = 2

func _on_obPlayerCount_item_selected(ID):
	if ID == 0:
		$pnStart/obChSlPl1.disabled = false
		
		$pnStart/obChSlPl2.disabled = true
		$pnStart/obChSlPl3.disabled = true
	
	if ID == 1:
		$pnStart/obChSlPl1.disabled = false
		$pnStart/obChSlPl2.disabled = false
		
		$pnStart/obChSlPl3.disabled = true
	
	if ID == 2:
		$pnStart/obChSlPl1.disabled = false
		$pnStart/obChSlPl2.disabled = false
		$pnStart/obChSlPl3.disabled = false 
	
	if $pnStart/obChSlPl1.disabled == false && $pnStart/obChSlPl1.selected == -1:
		$pnStart/obChSlPl1.selected = 0
	
	if $pnStart/obChSlPl2.disabled == false && $pnStart/obChSlPl2.selected == -1:
		$pnStart/obChSlPl2.selected = 1
	
	if $pnStart/obChSlPl3.disabled == false && $pnStart/obChSlPl3.selected == -1:
		$pnStart/obChSlPl3.selected = 2
	
	checkPlayerSelection()

func _on_obChSlPl_item_selected(ID, player_number):
	checkPlayerSelection(player_number)

func _on_btnOpDiscard_pressed():
	$pnOptions.visible = false
	$pnLeft/btnOptions.grab_focus()

func _on_btnOpOk_pressed():
	var globalDataNode = get_node("/root/GlobalDataStorage")
	
	for i in range(1, 4):
		# Save input method
		var input_method_id = get_node("pnOptions/obCtlPlayer" + String(i)).selected
		var input_method_str = get_node("pnOptions/obCtlPlayer" + String(i)).get_item_text(input_method_id)
		globalDataNode.set("player" + String(i) + "_input_method", input_method_str)
		
		# Save assigned gamepad
		globalDataNode.set("player" + String(i) + "_gamepad_nr", get("player" + String(i) + "_gamepad_nr"))
	
	_on_btnOpDiscard_pressed()

func _on_btnStStart_pressed():
	var globalDataNode = get_node("/root/GlobalDataStorage")
	
	# Save difficulty
	var difficulty_idx = $pnStart/obDifficulty.selected
	var difficulty_str = $pnStart/obDifficulty.get_item_text(difficulty_idx)
	globalDataNode.game_difficulty = difficulty_str
	
	# Save player count
	var player_count = $pnStart/obPlayerCount.selected
	globalDataNode.player_count = player_count + 1
	
	# Save character assignments
	for i in range(1, 4):
		var character_idx = get_node("pnStart/obChSlPl" + String(i)).selected
		var character_str = get_node("pnStart/obChSlPl" + String(i)).get_item_text(character_idx)
		globalDataNode.set("player" + String(i) + "_selected_character", character_str)
	
	emit_signal("game_started")

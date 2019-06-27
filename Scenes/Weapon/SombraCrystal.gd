extends Area2D

export(int, 0, 20) var std_damage = 1
export(String) var weapon_sound = "SimpleCrystalShotSound.wav"
export(float, -15.0, 15.0) var volume_db = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

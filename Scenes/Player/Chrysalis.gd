extends Area2D

export(float) var shoot_time_limit = 0.05
export(Vector2) var clamp_offset = Vector2(55, 60)
export(int) var shoot_speed = 1500
export(Vector2) var weapon_offset = Vector2(85, -60)
export(int, 0, 9999) var delay_px_offset = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#func emit_shoot(current_shot_lvl):
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

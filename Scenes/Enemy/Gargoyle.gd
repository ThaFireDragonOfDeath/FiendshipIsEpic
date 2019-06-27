extends Area2D

# Chances for random movements
var chances_x_movement = [20, 80]
var chances_y_movement = [80, 20]

# Chances for shoot sequences
var chances_shoot_seq = [80, 20]

# Available elements
var available_x_movements = ["Static", "R2L"]
var available_y_movements = ["Static", "UpAndDown"]
var available_shoot_seqs = ["StdRandomDirection", "FastSeq"]

# Other shoot parameters
var fast_seq_time_offset = 0.1
var fast_seq_bullet_count = 10

var min_shoot_angle = -3
var max_shoot_angle = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
extends Node2D

@export var speed_x_base: float = 2
@export var speed_x_random: float = 0.5
@export var distance_x: float = 5.0

var speed_x: float
var initial_x: float


func _ready() -> void:
	# Simpan posisi awal
	initial_x = position.x
	
	# Random variasi speed
	speed_x = speed_x_base + randf_range(-speed_x_random, speed_x_random)


func _process(delta: float) -> void:
	# Gerakan sway horizontal halus
	position.x = initial_x + sin(Time.get_ticks_msec() * 0.001 * speed_x) * distance_x
	

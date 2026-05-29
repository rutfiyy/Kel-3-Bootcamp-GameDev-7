extends Sprite2D

@export var rotation_speed_base: float = 1.0
@export var rotation_random: float = 0.5
@export var rotation_size: float = 0.05

var rotation_speed: float
var initial_rotation: float


func _ready() -> void:
	# Simpan rotasi lokal awal
	initial_rotation = rotation
	
	# Tambahkan variasi random ke kecepatan rotasi
	rotation_speed = rotation_speed_base + randf_range(-rotation_random, rotation_random)


func _process(delta: float) -> void:
	# Gerakan rotasi halus bolak-balik
	rotation = initial_rotation + sin(Time.get_ticks_msec() * 0.001 * rotation_speed) * rotation_size

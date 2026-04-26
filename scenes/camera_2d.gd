extends Camera2D

@export var player_path : NodePath   # nanti diisi manual di Inspector
@onready var player : Node2D = get_node(player_path)

# Batas area (sesuaikan dengan ukuran map kamu)
@export var map_left : float = 0.0
@export var map_right : float = 4000.0
@export var map_top : float = 0.0
@export var map_bottom : float = 1080.0

func _process(delta):
	if not player:
		return
	
	# Dapatkan posisi player
	var target_pos = player.global_position
	
	# Batasi posisi kamera agar tidak keluar map
	var new_x = clamp(target_pos.x, map_left, map_right)
	var new_y = clamp(target_pos.y, map_top, map_bottom)
	
	global_position = Vector2(new_x, new_y)

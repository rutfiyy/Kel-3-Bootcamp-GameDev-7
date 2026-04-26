extends Node2D

@export var ember_scene : PackedScene
@export var spawn_area : Rect2 = Rect2(100, 100, 1000, 600)
@export var max_embers : int = 15
@export var spawn_interval : float = 5.0

@onready var spawn_timer : Timer = $Timer

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	var embers = get_tree().get_nodes_in_group("ember")
	if embers.size() < max_embers:
		spawn_ember()

func spawn_ember():
	var ember = ember_scene.instantiate()
	ember.position = Vector2(
		randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	)
	get_parent().add_child(ember)

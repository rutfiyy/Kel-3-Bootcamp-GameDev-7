extends Node2D

@export var target_scene : PackedScene
@export var spawn_area : Vector2
@export var max_spawn : int = 15
@export var spawn_interval : float = 5.0
@export var spawn_group = "spawn_group"

@onready var player: Player = $"../../Player"

@onready var spawn_timer : Timer = $Timer

func _ready():
	player.win.connect(win)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	var scenes = get_tree().get_nodes_in_group(spawn_group)
	if scenes.size() < max_spawn:
		spawn_ember()

func spawn_ember():
	var new_scene = target_scene.instantiate()
	new_scene.add_to_group(spawn_group)
	#ember.position = Vector2(
		#randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x),
		#randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	#)
	new_scene.position = Vector2(
		randf_range(position.x - spawn_area.x/2, position.x + spawn_area.x/2),
		randf_range(position.y - spawn_area.y/2, position.y + spawn_area.y/2)
	)
	get_parent().add_child(new_scene)

func win() :
	spawn_timer.stop()

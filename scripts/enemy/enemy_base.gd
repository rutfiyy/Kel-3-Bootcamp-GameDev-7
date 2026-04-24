extends CharacterBody2D
class_name EnemyBase

@export var speed := 100
@export var size := 1
@export var ember_value := 1

@export_enum("NORMAL", "PREDATOR") var enemy_type: int

@onready var bt: BTPlayer = %BTPlayer

var is_alive: bool = true
var player

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	bt.blackboard.set_var("player", player)
	bt.blackboard.set_var("self_size", size)
	bt.blackboard.set_var("player_size", player.size)
	bt.blackboard.set_var("distance_to_player",
		global_position.distance_to(player.global_position))

func move_to(target: Vector2):
	var dir = (target - position).normalized()
	velocity = dir * speed
	move_and_slide()

func distance_to_player():
	return position.distance_to(player.position)

func can_be_eaten():
	return player.size > size

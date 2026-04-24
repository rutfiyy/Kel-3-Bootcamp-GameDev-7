extends BTAction

@export var speed: float = 100

func _tick(delta):
	var enemy = agent
	var player = blackboard.get_var("player")

	var dir = (enemy.global_position - player.global_position).normalized()
	enemy.velocity = dir * speed

	enemy.move_and_slide()

	return SUCCESS

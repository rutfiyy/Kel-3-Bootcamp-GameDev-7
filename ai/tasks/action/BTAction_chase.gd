extends BTAction

@export var speed: float = 120

func _tick(delta):
	var enemy = agent
	var player = blackboard.get_var("player")

	if not player:
		push_error("player not found")
		return FAILURE

	var dir = (player.global_position - enemy.global_position).normalized()
	enemy.velocity = dir * speed

	enemy.move_and_slide()

	return SUCCESS

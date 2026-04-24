extends BTAction

@export var speed: float = 80

var direction := Vector2.ZERO
var timer := 0.0

func _setup():
	direction = Vector2.RIGHT.rotated(randf() * TAU)
	timer = randf_range(1, 3)
	
func _tick(delta):
	timer -= delta

	if timer <= 0:
		direction = Vector2.RIGHT.rotated(randf() * TAU)
		timer = randf_range(1, 3)

	agent.velocity = direction * 50
	agent.move_and_slide()

	return SUCCESS

extends Area2D

@export var ember_value : int = 1

func _ready():
	add_to_group("ember")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if body.has_method("consume_ember"):
			body.consume_ember(ember_value)
			queue_free()

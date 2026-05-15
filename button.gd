extends Button

@export var dragonBones : Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	pressed.connect(PlayAnimation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func PlayAnimation() :
	dragonBones.play(text)

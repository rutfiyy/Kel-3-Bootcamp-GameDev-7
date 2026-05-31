extends Area2D

@export var speed : float = 500.0
var direction : Vector2 = Vector2.RIGHT

func _ready():
	add_to_group("bullet")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_area_entered(other_area: Area2D):
	# Jika mengenai hitbox musuh
	if other_area.is_in_group("enemy"):
		# Panggil fungsi die() di musuh (lewat parent)
		# Karena other_area adalah Hitbox (child), kita ambil parent-nya (Glowy)
		var enemy = other_area.get_parent()
		if enemy and enemy.has_method("die"):
			enemy.die()
		queue_free()

func _on_body_entered(body: Node2D):
	# Kena tile atau player, hancur
	queue_free()

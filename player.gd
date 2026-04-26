extends CharacterBody2D

# Movement
@export var speed : float = 250.0
@export var boost_multiplier : float = 2.0

# Size & Ember
@export var base_size : float = 1.0
@export var ember_value : int = 1

# Shrink mechanism
@export var idle_time_to_shrink : float = 3.0
@export var shrink_rate : float = 0.5
@export var max_idle_before_death : float = 10.0

var current_size : float = base_size
var is_moving : bool = false
var idle_timer : float = 0.0
var dead : bool = false
var frozen : bool = false
var last_direction : String = "right"

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var idle_check_timer : Timer = $IdleTimer

signal size_changed(new_size)
signal died

func _ready():
	add_to_group("player")
	update_visual_scale()
	animated_sprite.play("idle")
	idle_check_timer.timeout.connect(_on_idle_timer_timeout)

func _physics_process(delta):
	if dead or frozen:
		return
	
	# Input 4 arah (air, tanpa gravitasi)
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	var current_speed = speed
	if Input.is_action_pressed("boost"):
		current_speed *= boost_multiplier
	
	velocity = direction.normalized() * current_speed
	move_and_slide()
	
	# Update animasi
	if direction.length_squared() > 0.01:
		update_movement_animation(direction)
	else:
		play_idle()
	
	# Deteksi idle untuk shrink
	var was_moving = is_moving
	is_moving = direction.length_squared() > 0.01
	if is_moving and not was_moving:
		idle_timer = 0.0

# ----- ANIMASI -----
func update_movement_animation(dir: Vector2):
	if abs(dir.x) >= abs(dir.y):
		# Gerak horizontal dominan
		if dir.x > 0:
			animated_sprite.play("swim_right")
			animated_sprite.flip_h = false
			last_direction = "right"
		else:
			animated_sprite.play("swim_right")  # pakai animasi yang sama
			animated_sprite.flip_h = true       # flip biar hadap kiri
			last_direction = "left"
	else:
		# Gerak vertikal
		if dir.y > 0:
			animated_sprite.play("swim_down")
		else:
			animated_sprite.play("swim_up")
		animated_sprite.flip_h = false
		last_direction = "down" if dir.y > 0 else "up"

func play_idle():
	animated_sprite.play("idle")
	animated_sprite.flip_h = (last_direction == "left")

func consume_ember(value: int):
	if dead: return
	animated_sprite.play("eat")
	animated_sprite.flip_h = (last_direction == "left")
	grow(value)
	idle_timer = 0.0
	print("Ukuran Angie: ", current_size)

func consume_enemy(value: int):
	if dead: return
	animated_sprite.play("eat")
	animated_sprite.flip_h = (last_direction == "left")
	grow(value)
	idle_timer = 0.0
	print("Ukuran Angie: ", current_size)

# ----- SIZE & SHRINK -----
func grow(amount: int):
	current_size += amount * ember_value * 0.1
	update_visual_scale()
	size_changed.emit(current_size)

func shrink(amount: float):
	current_size = max(current_size - amount, 0.1)
	update_visual_scale()
	size_changed.emit(current_size)
	if current_size <= 0.1:
		die()

func update_visual_scale():
	animated_sprite.scale = Vector2(current_size, current_size)
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = 20.0 * current_size
	elif collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = Vector2(40, 40) * current_size

func _on_idle_timer_timeout():
	if dead or frozen: return
	if not is_moving:
		idle_timer += idle_check_timer.wait_time
		if idle_timer >= idle_time_to_shrink:
			shrink(shrink_rate * idle_check_timer.wait_time)
		if idle_timer >= max_idle_before_death:
			die()
	else:
		idle_timer = 0.0

func die():
	if dead: return
	dead = true
	velocity = Vector2.ZERO
	died.emit()

func freeze():
	frozen = true

func unfreeze():
	frozen = false

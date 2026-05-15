extends CharacterBody2D

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

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

# Shoot
@export var shoot_cooldown : float = 0.5

var current_size : float = base_size
var is_moving : bool = false
var idle_timer : float = 0.0
var dead : bool = false
var frozen : bool = false
var last_direction : String = "right"
var can_shoot : bool = true

# Untuk menghindari animasi dipanggil ulang setiap frame
var current_anim : String = ""

# 🎯 Sesuaikan nama node DragonBones kamu di scene
@onready var armature : DragonBonesArmatureView = $DragonBonesArmatureView
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var idle_check_timer : Timer = $IdleTimer

signal size_changed(new_size)
signal died

func _ready():
	add_to_group("player")
	update_visual_scale()
	idle_check_timer.timeout.connect(_on_idle_timer_timeout)
	
	# Perkecil ukuran awal (coba 0.3 atau 0.4)
	base_size = 0.2
	current_size = base_size
	update_visual_scale()
	
	await get_tree().process_frame
	_set_animation("idle")
# ----- FUNGSI AMAN UNTUK MENGATUR ANIMASI -----
func _set_animation(anim_name: String):
	# Hanya panggil play() jika animasi yang diinginkan berbeda
	if current_anim != anim_name:
		current_anim = anim_name
		armature.play(anim_name, -1)   # -1 = loop tanpa batas

# ----- GERAKAN -----
func _physics_process(delta):
	if dead or frozen:
		return
	
	# Input 4 arah (air)
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	var current_speed = speed
	if Input.is_action_pressed("boost"):
		current_speed *= boost_multiplier
	
	velocity = direction.normalized() * current_speed
	move_and_slide()
	
	# Animasi
	if direction.length_squared() > 0.01:
		update_movement_animation(direction)
	else:
		play_idle()
	
	# Shoot
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	# Idle detection (untuk shrink)
	var was_moving = is_moving
	is_moving = direction.length_squared() > 0.01
	if is_moving and not was_moving:
		idle_timer = 0.0

# ----- ANIMASI DRAGONBONES -----
func update_movement_animation(dir: Vector2):
	var anim_name = ""
	
	if abs(dir.x) >= abs(dir.y):
		# Gerak horizontal dominan → "move_forward"
		anim_name = "move_forward"
		if dir.x >= 0:
			# Hadap kanan
			armature.scale = Vector2(abs(armature.scale.x), armature.scale.y)
			last_direction = "right"
		else:
			# Hadap kiri (flip horizontal)
			armature.scale = Vector2(-abs(armature.scale.x), armature.scale.y)
			last_direction = "left"
	else:
		# Gerak vertikal
		if dir.y > 0:
			anim_name = "move_down"
		else:
			anim_name = "move_up"
		# Pastikan scale.x positif (tidak terbalik)
		armature.scale = Vector2(abs(armature.scale.x), armature.scale.y)
		last_direction = "down" if dir.y > 0 else "up"
	
	_set_animation(anim_name)

func play_idle():
	_set_animation("idle")
	# Pertahankan flip horizontal sesuai arah terakhir
	if last_direction == "left":
		armature.scale = Vector2(-abs(armature.scale.x), armature.scale.y)
	else:
		armature.scale = Vector2(abs(armature.scale.x), armature.scale.y)

# ----- UKURAN & SCALE (GROW/SHRINK) -----
func update_visual_scale():
	var size_scale = current_size
	var cur_scale = armature.scale
	var flip = -1 if cur_scale.x < 0 else 1
	armature.scale = Vector2(flip * size_scale, size_scale)
	
	# Update collision shape (sesuaikan dengan jenis shape)
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = 20.0 * current_size
	elif collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = Vector2(40, 40) * current_size

# ----- EMBER & GROWTH -----
func consume_ember(value: int):
	if dead: return
	
	# Karena belum ada animasi "eat", kita pinjam "move_down" sebentar
	_set_animation("move_down")
	await get_tree().create_timer(0.4).timeout
	play_idle()   # ini akan memanggil _set_animation("idle")
	
	grow(value)
	idle_timer = 0.0
	print("Ukuran Angie: ", current_size)

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
	# Tidak perlu armature.stop() agar tidak error
	died.emit()

func freeze():
	frozen = true

func unfreeze():
	frozen = false

# ----- SHOOT (EMBER SHOT) -----
func shoot():
	if not can_shoot or dead or frozen:
		return
	
	can_shoot = false
	
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	
	var offset = Vector2.ZERO
	match last_direction:
		"right": offset = Vector2(25, 0)
		"left": offset = Vector2(-25, 0)
		"up": offset = Vector2(0, -25)
		"down": offset = Vector2(0, 25)
	
	bullet.global_position = global_position + offset
	
	# Arah peluru
	match last_direction:
		"right": bullet.direction = Vector2.RIGHT
		"left": bullet.direction = Vector2.LEFT
		"up": bullet.direction = Vector2.UP
		"down": bullet.direction = Vector2.DOWN
	
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

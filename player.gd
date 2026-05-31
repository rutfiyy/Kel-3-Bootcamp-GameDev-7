class_name Player
extends CharacterBody2D

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

@export var speed : float = 250.0
@export var boost_multiplier : float = 2.0
@export var boost_ember_reduce_rate : float = 3.0
@export var base_scale : float = 0.3
@export var base_size : float = 1.0
@export var ember_value : float = 10
@export var ember_value_lag : float = 10
@export var ember_value_lag_update_speed : float = 10
@export var ember_value_max : float = 100
@export var ember_reduce_rate : float = 0.5
@export var ember_reduce_rate_default : float = 0.5
@export var ember_scale_min : float = 0.3
@export var ember_scale_max : float = 1.5
@export var ember_consume_rate : float = 1.0

@export var idle_time_to_shrink : float = 3.0
@export var shrink_rate : float = 0.5
@export var max_idle_before_death : float = 10.0
@export var shoot_cooldown : float = 0.5

@onready var fog: Sprite2D = $Fog
var fog_scale_min := 4.0
var fog_scale_max := 6.0

@onready var dragon_bones_armature_view: DragonBonesArmatureView = $DragonBonesArmatureView
var base_color = Vector4.ZERO
var brightness_min := 0.8
var brightness_max := 1.3

var current_size : float = base_size
var is_moving : bool = false
var idle_timer : float = 0.0
var dead : bool = false
var frozen : bool = false
var last_direction : String = "right"
var can_shoot : bool = true
var current_anim : String = ""
var angie_level = 1

@export var shrink_start : bool = false
@export var shrink_stop : bool = false
@export var shrink_duration : float = 3
@export var shrink_time : float = 0.0
@export var current_scale : Vector2

@onready var armature : DragonBonesArmatureView = $DragonBonesArmatureView
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var idle_check_timer : Timer = $IdleTimer

@onready var angie_level_label: Label = $"../UI/Control/AngieLevel"
@onready var ember_value_label: Label = $"../UI/Control/EmberValue"


signal size_changed(new_size)
signal died
signal win

func shrink_die(delta) :
	if shrink_stop :
		return
	if not shrink_start :
		return
	shrink_time += delta/shrink_duration
	scale = Vector2(current_scale.x*(1 - shrink_time), current_scale.y*(1 - shrink_time))
	if (shrink_time >= 0.5) :
		shrink_stop = true
		died.emit()

func _ready():
	add_to_group("player")
	update_visual_scale()
	if idle_check_timer.timeout.is_connected(_on_idle_timer_timeout):
		idle_check_timer.timeout.disconnect(_on_idle_timer_timeout)
	idle_check_timer.timeout.connect(_on_idle_timer_timeout)
	idle_check_timer.start()
	await get_tree().process_frame
	_set_animation("idle")

func _set_animation(anim_name: String):
	if current_anim != anim_name:
		current_anim = anim_name
		armature.play(anim_name, -1)

func _physics_process(delta):
	update_angie_level()
	shrink_die(delta)
	if dead or frozen:
		return
	var direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	# print("direction: ", direction)  # aktifkan jika perlu
	var current_speed = speed
	if Input.is_action_pressed("boost") and ember_value >= 20:
		current_speed *= boost_multiplier
		ember_reduce_rate = ember_reduce_rate_default * boost_ember_reduce_rate
	else :
		ember_reduce_rate = ember_reduce_rate_default
	velocity = direction.normalized() * current_speed
	move_and_slide()
	if direction.length_squared() > 0.01:
		update_movement_animation(direction)
	else:
		play_idle()
	if Input.is_action_just_pressed("shoot") and ember_value >= 40:
		shoot()
	var was_moving = is_moving
	is_moving = direction.length_squared() > 0.01
	if is_moving and not was_moving:
		idle_timer = 0.0
	ember_reduce(delta)
	update_scale(delta)
	update_ember_bar()
	update_ember_value_label()
	current_scale = scale
	
func update_ember_bar() :
	size_changed.emit(ember_value)
	
func ember_reduce(delta) :
	ember_value -= ember_reduce_rate * delta
	if ember_value <= 0 :
		die()

func update_scale(delta) :
	if ember_value > ember_value_lag :
		ember_value_lag += ember_value_lag_update_speed * delta
	elif ember_value < ember_value_lag :
		ember_value_lag -= ember_value_lag_update_speed * delta
	var angie_scale_factor = ember_scale_min + (ember_scale_max - ember_scale_min) * ember_value_lag / ember_value_max
	var fog_scale_factor = fog_scale_min + (fog_scale_max - fog_scale_min) * (ember_value_lag / ember_value_max) * (ember_value_lag / ember_value_max)
	var color_scale_factor = brightness_min + (brightness_max - brightness_min) * ember_value_lag / ember_value_max
	scale = Vector2(angie_scale_factor, angie_scale_factor)
	fog.scale = Vector2(fog_scale_factor, fog_scale_factor)
	var new_color = Color(color_scale_factor,color_scale_factor,color_scale_factor,1)
	dragon_bones_armature_view.modulate =new_color

func update_angie_level() :
	angie_level = (int(ember_value) / 20) +1
	angie_level_label.text = "Angie Level : " + str(angie_level) + "\n"
	match (angie_level) :
		1 : angie_level_label.text += "Eat ember (Small yellow ball)"
		2 : angie_level_label.text += "Eat small fish (Red fish)" + "\n" + "Boost Unlocked (Shift)"
		3 : angie_level_label.text += "Eat medium fish (Yellow fish)" + "\n" + "Boost Unlocked (Shift)" + "\n" + "Shoot Unlocked (Enter)"
		4 : angie_level_label.text += "Eat large fish (Green fish)" + "\n" + "Boost Unlocked (Shift)" + "\n" + "Shoot Unlocked (Enter)"
		5 : angie_level_label.text += "Eat voidfish (Black fish)" + "\n" + "Boost Unlocked (Shift)" + "\n" + "Shoot Unlocked (Enter)"

func update_movement_animation(dir: Vector2):
	var anim_name = ""
	if abs(dir.x) >= abs(dir.y):
		anim_name = "move_forward"
		if dir.x >= 0:
			armature.scale = Vector2(abs(armature.scale.x), armature.scale.y)
			last_direction = "right"
		else:
			armature.scale = Vector2(-abs(armature.scale.x), armature.scale.y)
			last_direction = "left"
	else:
		if dir.y > 0:
			anim_name = "move_down"
		else:
			anim_name = "move_up"
		armature.scale = Vector2(abs(armature.scale.x), armature.scale.y)
		last_direction = "down" if dir.y > 0 else "up"
	_set_animation(anim_name)

func play_idle():
	_set_animation("idle")
	if last_direction == "left":
		armature.scale = Vector2(-abs(armature.scale.x), armature.scale.y)
	else:
		armature.scale = Vector2(abs(armature.scale.x), armature.scale.y)

func update_visual_scale():
	var final_scale = base_scale * current_size
	var cur_scale = armature.scale
	var flip = -1 if cur_scale.x < 0 else 1
	armature.scale = Vector2(flip * final_scale, final_scale)
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = 20.0 * final_scale
	elif collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = Vector2(40, 40) * final_scale

func update_ember_value_label() :
	ember_value_label.text = str(int(ember_value))

func consume_ember(value: int):
	if dead:
		return
	ember_value += value*ember_consume_rate/angie_level
	if (ember_value > ember_value_max) :
		ember_value = ember_value_max
	#if dead: return
	#_set_animation("move_down")
	#await get_tree().create_timer(0.4).timeout
	#play_idle()
	#grow(value)
	#idle_timer = 0.0
	#print("Ukuran Angie: ", current_size)

func grow(amount: int):
	pass
	#current_size += amount * ember_value * 0.2
	#update_visual_scale()
	#size_changed.emit(current_size)

func shrink(amount: float):
	print("SHRINK CALLED! amount=", amount, " current_size before=", current_size)
	current_size = max(current_size - amount, 0.1)
	update_visual_scale()
	size_changed.emit(current_size)
	print("current_size after=", current_size)
	if current_size <= 0.1:
		die()

func _on_idle_timer_timeout():
	if dead or frozen:
		return
	#print("DEBUG: is_moving=", is_moving, " idle_timer=", idle_timer)
	if not is_moving:
		idle_timer += idle_check_timer.wait_time
		print("   idle_timer after +: ", idle_timer, " (shrink at ", idle_time_to_shrink, ")")
		if idle_timer >= idle_time_to_shrink:
			print(">>> MEMANGGIL shrink() SEKARANG! <<<")
			#shrink(shrink_rate * idle_check_timer.wait_time)
			idle_timer = 0.0  # reset supaya tidak terus-menerus menyusut dalam satu detik
		#if idle_timer >= max_idle_before_death:
		#	die()
	else:
		idle_timer = 0.0

func die():
	if dead: return
	shrink_start = true
	dead = true
	velocity = Vector2.ZERO

func freeze(): frozen = true
func unfreeze(): frozen = false

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
	match last_direction:
		"right": bullet.direction = Vector2.RIGHT
		"left": bullet.direction = Vector2.LEFT
		"up": bullet.direction = Vector2.UP
		"down": bullet.direction = Vector2.DOWN
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

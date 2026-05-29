extends CharacterBody2D

enum State { WALK, IDLE, TURN }

@export var move_speed : float = 80.0
@export var ember_value : int = 1
@export var base_scale : float = 0.5
@export var sprite_faces_right : bool = false
@export var min_state_time : float = 1.5
@export var max_state_time : float = 3.5
@export var enemy_size : int = 1

var dead : bool = false
var current_state : State = State.WALK
var direction : int = 1
var current_anim : String = ""

@onready var armature : DragonBonesArmatureView = $DragonBonesArmatureView
@onready var hitbox : Area2D = $Hitbox
@onready var state_timer : Timer = $StateTimer

func _ready():
	add_to_group("enemy")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	state_timer.timeout.connect(_on_state_timer_timeout)
	_pick_new_state()
	await get_tree().process_frame
	update_visual()

func _pick_new_state():
	var rng = randi() % 3
	match rng:
		0: current_state = State.WALK
		1: current_state = State.IDLE
		2: current_state = State.TURN
	state_timer.start(randf_range(min_state_time, max_state_time))

func _on_state_timer_timeout():
	_pick_new_state()

func _physics_process(delta):
	if dead: return
	match current_state:
		State.WALK:
			velocity.x = direction * move_speed
			_set_animation("walk")
		State.IDLE:
			velocity.x = 0
			_set_animation("walk")
		State.TURN:
			direction *= -1
			update_visual()
			current_state = State.WALK
			velocity.x = direction * move_speed
			_set_animation("walk")
	move_and_slide()
	if is_on_wall():
		direction *= -1
		update_visual()

func _set_animation(anim_name: String):
	if current_anim != anim_name:
		current_anim = anim_name
		armature.play(anim_name, -1)

func update_visual():
	var flip = 1
	if sprite_faces_right:
		flip = 1 if direction == 1 else -1
	else:
		flip = -1 if direction == 1 else 1
	armature.scale = Vector2(base_scale * flip, base_scale)

func _on_hitbox_area_entered(area: Area2D):
	if dead: return
	if area.is_in_group("bullet"):
		area.queue_free()
		die()

func _on_hitbox_body_entered(body: Node2D):
	if dead: return
	if body.is_in_group("player") and body.has_method("consume_ember"):
		var player_size = body.get("current_size")
		if player_size == null:
			player_size = 0.0
		if player_size >= enemy_size:
			body.consume_ember(ember_value)
			die()
		else:
			print("Angie terlalu kecil untuk makan musuh ini")

func die():
	if dead: return
	dead = true
	call_deferred("spawn_ember")
	queue_free()

func spawn_ember():
	var ember_scene = load("res://scenes/ember.tscn")
	if ember_scene:
		var e = ember_scene.instantiate()
		e.global_position = global_position
		get_parent().add_child(e)

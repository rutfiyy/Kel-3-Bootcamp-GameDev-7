extends Node

enum State {
	INACTIVE,
	WARNING,
	ATTACK,
	EXIT,
	COOLDOWN
}

enum AttackType {
	LUNGE,
	SHADOW_BREATH
}

# ===== CONFIG =====
@export_category("References")
@export var voidfin_scene: PackedScene
@export var red_eyes_scene: PackedScene

@export_category("Settings")
@export_group("spawn")
@export var idle_threshold := 3.0
@export var min_size := 8
@export var spawn_chance := 0.4

@export_group("timer")
@export var active_duration := Vector2(45.0, 60.0)
@export var warning_duration := 0.8
@export var attack_delay := Vector2(1.0, 3.0)
@export var cooldown_time := 20.0

# ===== RUNTIME =====
var player
var state = State.INACTIVE
var is_active := false

# warning phase
var attack_direction = ""
var attack_position : Vector2 = Vector2.ZERO
var current_attack
var current_red_eyes = null

# attack phase
var voidfin_attacking := false

# timer
var idle_timer := 0.0
var active_timer := 0.0
var warning_timer := 0.0
var attack_timer := 0.0
var cooldown_timer := 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	update_timer(delta)

	match state:
		State.INACTIVE:
			process_inactive()

		State.WARNING:
			process_warning(delta)

		State.ATTACK:
			process_attack()

		State.EXIT:
			process_exit()

		State.COOLDOWN:
			process_cooldown(delta)

func update_timer(delta):
	if is_active:
		active_timer -= delta

		if active_timer <= 0:
			end_active_phase()
			return
	else:
		if player.velocity.length() < 5:
			idle_timer += delta
		else:
			idle_timer = 0

#region inactive phase
func process_inactive():
	if player.size < min_size:
		return

	if idle_timer < idle_threshold:
		return

	if randf() > spawn_chance:
		idle_timer = 0
		return

	start_active_phase()

func start_active_phase():
	is_active = true
	active_timer = randf_range(active_duration.x, active_duration.y)

	print("VOIDFIN ACTIVE")

	go_to_warning()

#endregion

#region warning phase
func go_to_warning():
	state = State.WARNING
	warning_timer = warning_duration

	pick_attack()
	pick_attack_direction()
	spawn_red_eyes()

	print("WARNING - RED EYES")

func process_warning(delta):
	warning_timer -= delta

	if warning_timer <= 0:
		remove_red_eyes()
		state = State.ATTACK

func pick_attack():
	var attacks = [AttackType.LUNGE, AttackType.SHADOW_BREATH]
	current_attack = attacks.pick_random()
	
	match current_attack:
		AttackType.LUNGE:
			print("Attack: Lunge Attack")
		AttackType.SHADOW_BREATH:
			print("Attack: Shadow Breath Attack")

func pick_attack_direction():
	if current_attack == AttackType.SHADOW_BREATH:
		var dirs = ["left", "right"]
		attack_direction = dirs.pick_random()
	else:
		var dirs = ["left", "right", "bottom"]
		attack_direction = dirs.pick_random()

	print("Direction:", attack_direction)

func spawn_red_eyes():
	var eyes = red_eyes_scene.instantiate()

	var camera = get_viewport().get_camera_2d()
	var screen_size = get_viewport().get_visible_rect().size
	var center = camera.global_position

	attack_position = Vector2.ZERO

	match current_attack:
		AttackType.LUNGE:
			match attack_direction:
				"left":
					attack_position = center + Vector2(-screen_size.x/2 + 40, randf_range(-screen_size.y/2, screen_size.y/2))

				"right":
					attack_position = center + Vector2(screen_size.x/2 - 40, randf_range(-screen_size.y/2, screen_size.y/2))

				"bottom":
					attack_position = center + Vector2(randf_range(-screen_size.x/2, screen_size.x/2), screen_size.y/2 - 40)
		AttackType.SHADOW_BREATH:
			match attack_direction:
				"left":
					attack_position = center + Vector2(-screen_size.x/2 + 40, 0)

				"right":
					attack_position = center + Vector2(screen_size.x/2 - 40, 0)			
	
	eyes.global_position = attack_position

	get_tree().current_scene.add_child(eyes)

	current_red_eyes = eyes

func remove_red_eyes():
	if current_red_eyes:
		current_red_eyes.queue_free()
		current_red_eyes = null

#endregion

#region attack phase
func process_attack():
	if !voidfin_attacking:
		print("ATTACK START")
		voidfin_attacking = true
		match current_attack:
			AttackType.LUNGE:
				spawn_lunge()

			AttackType.SHADOW_BREATH:
				spawn_shadow_breath()

func spawn_lunge():
	var voidfin = voidfin_scene.instantiate() as Voidfin
	voidfin.exit_screen.connect(
	func(): 
		voidfin_attacking = false
		state = State.EXIT
	)

	var spawn_pos = Vector2.ZERO
	var dir = Vector2.ZERO
	
	match attack_direction:
		"left":
			spawn_pos = attack_position + Vector2(-10, 0)
			dir = Vector2.RIGHT

		"right":
			spawn_pos = attack_position + Vector2(10, 0)
			dir = Vector2.LEFT

		"bottom":
			spawn_pos = attack_position + Vector2(0, 10)
			dir = Vector2.UP

	voidfin.global_position = spawn_pos

	get_tree().current_scene.add_child(voidfin)
	
	voidfin.start_dash(dir)

func spawn_shadow_breath():
	var voidfin = voidfin_scene.instantiate() as Voidfin
	voidfin.exit_screen.connect(
	func(): 
		voidfin_attacking = false
		state = State.EXIT
	)

	var spawn_pos = Vector2.ZERO

	match attack_direction:
		"left":
			spawn_pos = attack_position + Vector2(40, 0)

		"right":
			spawn_pos = attack_position + Vector2(-40, 0)

	voidfin.global_position = spawn_pos
	get_tree().current_scene.add_child(voidfin)

	voidfin.start_shadow_breath(player, attack_direction)

#endregion

#region exit phase
func process_exit():
	print("EXIT")

	attack_timer = randf_range(attack_delay.x, attack_delay.y)
	state = State.COOLDOWN

func end_active_phase():
	print("VOIDFIN DESPAWN")

	is_active = false
	state = State.COOLDOWN

	cooldown_timer = cooldown_time

#endregion

#region cooldown phase
func process_cooldown(delta):
	if is_active:
		attack_timer -= delta
		
		if attack_timer <= 0:
			go_to_warning()
	else:
		# global cooldown
		cooldown_timer -= delta

		if cooldown_timer <= 0:
			state = State.INACTIVE

#endregion

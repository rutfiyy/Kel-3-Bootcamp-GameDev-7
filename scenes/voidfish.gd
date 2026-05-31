extends Enemy

enum VoidfishState {
	FOLLOWING_SLOW,
	FOLLOWING_MEDIUM,
	FOLLOWING_FAST,
	FOLLOWING_VERY_FAST,
	FLEE,
	FLEE_TEMPORARY,
}

@export var speed_multiplier_medium : float = 1.6
@export var speed_multiplier_fast : float = 2.0
@export var speed_multiplier_very_fast : float = 2.4
@export var speed_multiplier_flee : float = 2.4
@export var speed_multiplier_flee_temporary : float = 2.4
@export var speed_multiplier_keep_up : float = 10.0

@export var keep_up_distance : int = 1000
@export var flee_distance : int = 800
@export var flee_duration : int = 3

@onready var red_eye: Node2D = $RedEyeContainer

var following_state : VoidfishState = VoidfishState.FOLLOWING_SLOW

var flee_timer : float = 0.0

func on_ember_changed(ember : float) -> void:

	# jangan override state sementara
	if following_state == VoidfishState.FLEE_TEMPORARY:
		return

	if ember < 20:
		change_state(VoidfishState.FOLLOWING_SLOW)

	elif ember < 40:
		change_state(VoidfishState.FOLLOWING_MEDIUM)

	elif ember < 60:
		change_state(VoidfishState.FOLLOWING_FAST)

	elif ember < 80:
		change_state(VoidfishState.FOLLOWING_VERY_FAST)

	else:
		change_state(VoidfishState.FLEE)


func change_state(new_state : VoidfishState) -> void:

	if following_state == new_state:
		return

	following_state = new_state

	match following_state:

		VoidfishState.FOLLOWING_SLOW:
			print("Voidfish: FOLLOWING_SLOW")

		VoidfishState.FOLLOWING_MEDIUM:
			print("Voidfish: FOLLOWING_MEDIUM")

		VoidfishState.FOLLOWING_FAST:
			print("Voidfish: FOLLOWING_FAST")

		VoidfishState.FLEE:
			print("Voidfish: FLEE")

		VoidfishState.FLEE_TEMPORARY:
			print("Voidfish: FLEE_TEMPORARY")


# ini override, move_and_slide ada di script Enemy
func move(delta: float) -> void:
	on_ember_changed(player.ember_value)
	_set_animation("walk")
	if global_position.x - player.global_position.x > 0 :
		armature.scale = Vector2(1,1)
		red_eye.scale = Vector2(1,1)
	elif global_position.x - player.global_position.x < 0 :
		armature.scale = Vector2(-1,1)
		red_eye.scale = Vector2(-1,1)
	if following_state == VoidfishState.FLEE or following_state == VoidfishState.FLEE_TEMPORARY :
		armature.scale = Vector2(-armature.scale.x, armature.scale.y)
		red_eye.scale = Vector2(-red_eye.scale.x, red_eye.scale.y)
	# update timer flee sementara
	if following_state == VoidfishState.FLEE_TEMPORARY:

		flee_timer -= delta

		if flee_timer <= 0:
			following_state = VoidfishState.FOLLOWING_SLOW


	var distance_to_player : float = global_position.distance_to(player.global_position)

	match following_state:

		VoidfishState.FOLLOWING_SLOW:

			if distance_to_player > keep_up_distance:
				follow_player(move_speed * speed_multiplier_keep_up)
			else:
				follow_player(move_speed)


		VoidfishState.FOLLOWING_MEDIUM:

			if distance_to_player > keep_up_distance:
				follow_player(move_speed * speed_multiplier_keep_up)
			else:
				follow_player(move_speed * speed_multiplier_medium)


		VoidfishState.FOLLOWING_FAST:

			if distance_to_player > keep_up_distance:
				follow_player(move_speed * speed_multiplier_keep_up)
			else:
				follow_player(move_speed * speed_multiplier_fast)
		
		VoidfishState.FOLLOWING_VERY_FAST:

			if distance_to_player > keep_up_distance:
				follow_player(move_speed * speed_multiplier_keep_up)
			else:
				follow_player(move_speed * speed_multiplier_very_fast)

		VoidfishState.FLEE:

			# terlalu dekat -> kabur
			if distance_to_player < flee_distance:
				run_away_from_player(move_speed * speed_multiplier_flee)

			# terlalu jauh -> mendekat lagi
			elif distance_to_player > keep_up_distance:
				follow_player(move_speed * speed_multiplier_keep_up)

			# jarak ideal -> diam
			else:
				velocity = Vector2.ZERO


		VoidfishState.FLEE_TEMPORARY:

			run_away_from_player(move_speed * speed_multiplier_flee_temporary)


func follow_player(speed : float) -> void:

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed


func run_away_from_player(speed : float) -> void:

	var direction = (global_position - player.global_position).normalized()
	velocity = direction * speed


func take_damage() -> void:

	flee_timer = flee_duration
	change_state(VoidfishState.FLEE_TEMPORARY)

func die_animation_completed() :
	print("win")
	player.win.emit()

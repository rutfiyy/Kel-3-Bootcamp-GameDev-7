extends CharacterBody2D
class_name Voidfin

var direction := Vector2.ZERO
var speed := 400
var is_active := false
var has_appear := false
var mode = "dash"
var target_player
var breath_time := 3.0

signal exit_screen

func start_dash(dir: Vector2):
	mode = "dash"
	direction = dir.normalized()
	is_active = true

func start_shadow_breath(p, dir):
	mode = "breath"
	target_player = p
	direction = (p.global_position - global_position).normalized()
	is_active = true

func _physics_process(delta):
	if not is_active:
		return

	if mode == "dash":
		velocity = direction * speed

	elif mode == "breath":
		velocity = Vector2.ZERO
		apply_pull(delta)

		breath_time -= delta
		if breath_time <= 0:
			exit_screen.emit()
			queue_free()

	move_and_slide()

	if mode == "dash" and is_out_of_screen():
		if has_appear:
			exit_screen.emit()
			queue_free()
	else:
		has_appear = true

func apply_pull(delta):
	if target_player == null:
		return

	var dir_to_voidfin = (global_position - target_player.global_position)
	var dist = dir_to_voidfin.length()

	#if dist < 400:
		#var pull_force = dir_to_voidfin.normalized() * (500 / max(dist, 50))
		#target_player.velocity += pull_force * delta
	var pull_force = dir_to_voidfin.normalized() * (50000 / max(dist, 50))
	target_player.position += pull_force * delta

func is_out_of_screen() -> bool:
	var camera = get_viewport().get_camera_2d()
	if camera == null:
		return false

	var screen_rect = Rect2(
		camera.global_position - get_viewport_rect().size / 2,
		get_viewport_rect().size
	)

	return not screen_rect.has_point(global_position)

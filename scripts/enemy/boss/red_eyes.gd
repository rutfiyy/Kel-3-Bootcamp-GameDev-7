extends Node2D

@export var blink_speed := 6.0

func _process(delta):
	# efek kedip (alpha naik turun)
	var t = sin(Time.get_ticks_msec() / 1000.0 * blink_speed)
	modulate.a = 0.5 + 0.5 * abs(t)

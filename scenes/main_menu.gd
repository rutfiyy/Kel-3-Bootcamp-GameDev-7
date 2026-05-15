extends Control

var settings_panel : Control = null

func _ready():
	# Tampilkan kursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Hubungkan tombol utama
	$Control/PlayButton.pressed.connect(_on_play_pressed)
	$Control/OptionsButton.pressed.connect(_on_options_pressed)
	$Control/ExitButton.pressed.connect(_on_exit_pressed)
	
	# Load panel settings (hanya satu kali)
	settings_panel = preload("res://scenes/settings_panel.tscn").instantiate()
	add_child(settings_panel)
	settings_panel.hide()

func _on_play_pressed():
	# Sembunyikan kursor untuk gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed():
	# Tampilkan panel settings
	if settings_panel:
		settings_panel.show()

func _on_exit_pressed():
	get_tree().quit()

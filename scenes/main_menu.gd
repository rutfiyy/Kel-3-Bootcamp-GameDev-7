extends Control

<<<<<<< HEAD
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
=======
func _ready():
	# Hubungkan sinyal tombol secara manual (biar lebih jelas)
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	# Pindah ke scene gameplay utama
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_options_pressed():
	# Sementara kosongin aja, nanti bisa ditambah panel settings
	print("Options pressed - belum implementasi")
>>>>>>> 4ae7846fd1a63e11ed05b0d54d54b484105bf62d

func _on_exit_pressed():
	get_tree().quit()

extends Control

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

func _on_exit_pressed():
	get_tree().quit()

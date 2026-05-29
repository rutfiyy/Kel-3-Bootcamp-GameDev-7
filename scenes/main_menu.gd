extends Control

@onready var exit_confirm : ConfirmationDialog = %ExitConfirm
var settings_panel : Control = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Matikan paksa semua popup yang tidak sengaja muncul
	_exit_confirm_hide()
	_hide_all_popups()
	
	# Load settings panel (bukan popup)
	settings_panel = preload("res://scenes/settings_panel.tscn").instantiate()
	add_child(settings_panel)
	settings_panel.hide()
	
	# Hubungkan tombol
	$Control/PlayButton.pressed.connect(_on_play_pressed)
	$Control/OptionsButton.pressed.connect(_on_options_pressed)
	$Control/ExitButton.pressed.connect(_on_exit_pressed)
	
	exit_confirm.confirmed.connect(func(): get_tree().quit())

func _exit_confirm_hide():
	if exit_confirm:
		exit_confirm.hide()
		exit_confirm.visible = false

func _hide_all_popups():
	# Cari semua node Popup di dalam scene ini dan sembunyikan
	for child in get_children():
		if child is Popup or child is PopupPanel or child is ConfirmationDialog:
			child.hide()
			child.visible = false

func _on_play_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://scenes/levels/level_1_sample.tscn")

func _on_options_pressed():
	settings_panel.show()

func _on_exit_pressed():
	exit_confirm.popup_centered()

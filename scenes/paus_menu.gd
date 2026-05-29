extends Control

@onready var resume_btn : Button = %ResumeBtn
@onready var options_btn : Button = %OptionsBtn
@onready var quit_btn : Button = %QuitBtn
@onready var quit_confirm : ConfirmationDialog = %QuitConfirm

signal resume_game
signal open_settings
signal quit_to_menu

func _ready():
	# Pastikan tombol bisa menerima input saat game paused
	resume_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	options_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	quit_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	
	resume_btn.pressed.connect(_on_resume_pressed)
	options_btn.pressed.connect(_on_options_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	quit_confirm.confirmed.connect(_on_quit_confirmed)

func _on_resume_pressed():
	print("Resume button pressed")
	hide()
	get_tree().paused = false
	resume_game.emit()

func _on_options_pressed():
	print("Options button pressed")
	open_settings.emit()

func _on_quit_pressed():
	quit_confirm.popup_centered()

func _on_quit_confirmed():
	get_tree().paused = false
	quit_to_menu.emit()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

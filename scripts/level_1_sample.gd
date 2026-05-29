extends Node2D

# --- UI Utama ---
@onready var size_label : Label = get_node_or_null("%Label") as Label
@onready var ember_bar : TextureProgressBar = get_node_or_null("%EmberBar") as TextureProgressBar
@onready var boost_bar : ProgressBar = get_node_or_null("%BoostBar") as ProgressBar
@onready var game_over_panel : Panel = get_node_or_null("%GameOverPanel") as Panel
@onready var level_complete_panel : Panel = get_node_or_null("%LevelCompletePanel") as Panel
@onready var settings_button : Button = get_node_or_null("%SettingsButton") as Button
@onready var ui_layer : CanvasLayer = %UI

var max_player_size : float = 3.0

# --- Panel Settings & Pause ---
var settings_popup : PopupPanel = null
var pause_menu : Control = null

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	if game_over_panel:
		game_over_panel.visible = false
		game_over_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if level_complete_panel:
		level_complete_panel.visible = false
		level_complete_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.size_changed.connect(_on_player_size_changed)
		_on_player_size_changed(player.current_size)
		if player.has_signal("died"):
			player.died.connect(_on_player_died)

	# Tombol-tombol (pakai % unique name langsung)
	if game_over_panel:
		var retry_btn = get_node_or_null("%RetryButton") as Button
		if retry_btn:
			retry_btn.process_mode = Node.PROCESS_MODE_ALWAYS
			retry_btn.pressed.connect(_on_retry_pressed)
		var menu_btn_go = get_node_or_null("%GOMenuButton") as Button   # sesuaikan nama unikmu
		if menu_btn_go:
			menu_btn_go.process_mode = Node.PROCESS_MODE_ALWAYS
			menu_btn_go.pressed.connect(_on_menu_pressed)

	if level_complete_panel:
		var next_btn = get_node_or_null("%NextButton") as Button
		if next_btn:
			next_btn.process_mode = Node.PROCESS_MODE_ALWAYS
			next_btn.pressed.connect(_on_next_level_pressed)
		var menu_btn_lc = get_node_or_null("%LCMenuButton") as Button   # sesuaikan nama unikmu
		if menu_btn_lc:
			menu_btn_lc.process_mode = Node.PROCESS_MODE_ALWAYS
			menu_btn_lc.pressed.connect(_on_menu_pressed)

	# Load Settings Popup
	settings_popup = preload("res://settings_popup.tscn").instantiate()
	ui_layer.add_child(settings_popup)
	settings_popup.hide()
	settings_popup.closed.connect(_on_settings_closed)

	# Load Pause Menu
	pause_menu = preload("res://scenes/paus_menu.tscn").instantiate()
	ui_layer.add_child(pause_menu)
	pause_menu.hide()
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.open_settings.connect(_on_open_settings_from_pause)

	if settings_button:
		settings_button.pressed.connect(_on_settings_button_pressed)

# ---------- SINYAL UI ----------
func _on_player_size_changed(new_size: float):
	if size_label:
		size_label.text = "Ukuran: %.2f" % new_size
	if ember_bar:
		ember_bar.value = clamp(new_size / max_player_size * 100.0, 0.0, 100.0)

func _on_player_died():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if game_over_panel:
		game_over_panel.visible = true
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("freeze"):
		player.freeze()
	var spawner = get_node_or_null("Spawner")
	if spawner and spawner.has_method("stop"):
		spawner.stop()

func _on_retry_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().reload_current_scene()

func _on_menu_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_next_level_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().reload_current_scene()

func _on_settings_button_pressed():
	pause_menu.show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if settings_popup.visible:
			settings_popup.hide()
			_on_settings_closed()
		elif pause_menu.visible:
			pause_menu.hide()
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		else:
			pause_menu.show()
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_resume_game():
	if settings_popup.visible:
		settings_popup.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _on_open_settings_from_pause():
	settings_popup.popup_centered()

func _on_settings_closed():
	if pause_menu and pause_menu.visible:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		get_tree().paused = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if level_complete_panel:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			level_complete_panel.visible = true
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("freeze"):
				player.freeze()
			var spawner = get_node_or_null("Spawner")
			if spawner and spawner.has_method("stop"):
				spawner.stop()

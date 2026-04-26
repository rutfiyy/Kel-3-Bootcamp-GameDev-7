extends Node2D

# Referensi UI (pakai % unique name, aman kalau belum ada)
@onready var size_label : Label = get_node_or_null("%Label") as Label
@onready var ember_bar : ProgressBar = get_node_or_null("%EmberBar") as ProgressBar
@onready var game_over_panel : Panel = get_node_or_null("%GameOverPanel") as Panel
@onready var level_complete_panel : Panel = get_node_or_null("%LevelCompletePanel") as Panel

var max_player_size : float = 3.0   # batas ukuran untuk bar penuh (sesuaikan)

func _ready():
	# Sembunyikan kursor saat gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	# Sembunyikan panel awal
	if game_over_panel:
		game_over_panel.visible = false
		game_over_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if level_complete_panel:
		level_complete_panel.visible = false
		level_complete_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Cari player dan hubungkan sinyal
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.size_changed.connect(_on_player_size_changed)
		_on_player_size_changed(player.current_size)
		
		if player.has_signal("died"):
			player.died.connect(_on_player_died)
	
	# Hubungkan tombol-tombol UI
	if game_over_panel:
		var retry_btn = game_over_panel.get_node_or_null("VBoxContainer/RetryButton") as Button
		if retry_btn:
			retry_btn.pressed.connect(_on_retry_pressed)
		var menu_btn_go = game_over_panel.get_node_or_null("VBoxContainer/MenuButton") as Button
		if menu_btn_go:
			menu_btn_go.pressed.connect(_on_menu_pressed)
	
	if level_complete_panel:
		var next_btn = level_complete_panel.get_node_or_null("VBoxContainer/NextButton") as Button
		if next_btn:
			next_btn.pressed.connect(_on_next_level_pressed)
		var menu_btn_lc = level_complete_panel.get_node_or_null("VBoxContainer/MenuButton") as Button
		if menu_btn_lc:
			menu_btn_lc.pressed.connect(_on_menu_pressed)

func _on_player_size_changed(new_size: float):
	if size_label:
		size_label.text = "Ukuran: %.2f" % new_size
	
	if ember_bar:
		var bar_value = clamp(new_size / max_player_size * 100.0, 0.0, 100.0)
		ember_bar.value = bar_value

func _on_player_died():
	# Munculkan kursor agar bisa klik tombol
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if game_over_panel:
		game_over_panel.visible = true
	
	# Hentikan player dan spawner
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
	# Untuk sementara reload, nanti ganti ke scene zona 2
	get_tree().reload_current_scene()

# Debug: tekan Enter untuk tes Level Complete
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if level_complete_panel:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			level_complete_panel.visible = true
			
			# Freeze player & spawner saat panel muncul
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("freeze"):
				player.freeze()
			var spawner = get_node_or_null("Spawner")
			if spawner and spawner.has_method("stop"):
				spawner.stop()

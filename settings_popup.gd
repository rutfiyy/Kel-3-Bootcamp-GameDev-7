extends PopupPanel

@onready var music_slider : HSlider = %MusicSlider
@onready var sfx_slider : HSlider = %SFXSlider
@onready var bright_slider : HSlider = %BrightnessSlider
@onready var music_value : Label = %MusicValue
@onready var sfx_value : Label = %SFXValue
@onready var bright_value : Label = %BrightnessValue
@onready var res_option : OptionButton = %ResolutionOption
@onready var full_check : CheckBox = %FullscreenCheck
@onready var vsync_check : CheckBox = %VsyncCheck
@onready var subtitles_check : CheckBox = %SubtitlesCheck
@onready var apply_btn : Button = %ApplyButton
@onready var ok_btn : Button = %OkButton
@onready var cancel_btn : Button = %CancelButton

var bgm_bus : int = -1
var sfx_bus : int = -1

signal closed

func _ready():
	bgm_bus = AudioServer.get_bus_index("BGM")
	sfx_bus = AudioServer.get_bus_index("SFX")
	
	_load_settings()
	
	music_slider.value_changed.connect(func(v): music_value.text = str(v); _apply_audio())
	sfx_slider.value_changed.connect(func(v): sfx_value.text = str(v); _apply_audio())
	bright_slider.value_changed.connect(func(v): bright_value.text = str(v))
	
	apply_btn.pressed.connect(_apply_all)
	ok_btn.pressed.connect(func(): _apply_all(); hide(); closed.emit())
	cancel_btn.pressed.connect(func(): _load_settings(); hide(); closed.emit())

func _load_settings():
	if bgm_bus != -1:
		var v = db_to_percent(AudioServer.get_bus_volume_db(bgm_bus))
		music_slider.value = v; music_value.text = str(v)
	if sfx_bus != -1:
		var v = db_to_percent(AudioServer.get_bus_volume_db(sfx_bus))
		sfx_slider.value = v; sfx_value.text = str(v)
	bright_slider.value = 50; bright_value.text = "50"
	res_option.selected = _res_index(DisplayServer.window_get_size())
	full_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED

func _apply_audio():
	if bgm_bus != -1: AudioServer.set_bus_volume_db(bgm_bus, percent_to_db(music_slider.value))
	if sfx_bus != -1: AudioServer.set_bus_volume_db(sfx_bus, percent_to_db(sfx_slider.value))

func _apply_all():
	_apply_audio()
	var res_str = res_option.get_item_text(res_option.selected)
	var parts = res_str.split("x")
	DisplayServer.window_set_size(Vector2i(int(parts[0]), int(parts[1])))
	if full_check.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_check.button_pressed else DisplayServer.VSYNC_DISABLED)

func percent_to_db(p: float) -> float: return linear_to_db(p / 100.0)
func db_to_percent(db: float) -> float: return db_to_linear(db) * 100.0

func _res_index(size: Vector2i) -> int:
	if size.x >= 2560: return 3
	elif size.x >= 1920: return 2
	elif size.x >= 1600: return 1
	return 0

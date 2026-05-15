extends Control

@onready var bgm_slider : HSlider = %BGMSlider
@onready var sfx_slider : HSlider = %SFXSlider
@onready var back_button : Button = %BackButton

var bgm_bus_index : int = -1
var sfx_bus_index : int = -1

signal closed

func _ready():
	# Dapatkan index bus audio (pastikan bus sudah dibuat)
	bgm_bus_index = AudioServer.get_bus_index("BGM")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	# Hanya set slider jika bus ada
	if bgm_bus_index != -1:
		bgm_slider.value = db_to_percent(AudioServer.get_bus_volume_db(bgm_bus_index))
		bgm_slider.value_changed.connect(func(v: float):
			AudioServer.set_bus_volume_db(bgm_bus_index, percent_to_db(v))
		)
	
	if sfx_bus_index != -1:
		sfx_slider.value = db_to_percent(AudioServer.get_bus_volume_db(sfx_bus_index))
		sfx_slider.value_changed.connect(func(v: float):
			AudioServer.set_bus_volume_db(sfx_bus_index, percent_to_db(v))
		)
	
	back_button.pressed.connect(func():
		hide()
		closed.emit()
	)

func percent_to_db(percent: float) -> float:
	return linear_to_db(percent / 100.0)

func db_to_percent(db: float) -> float:
	return db_to_linear(db) * 100.0

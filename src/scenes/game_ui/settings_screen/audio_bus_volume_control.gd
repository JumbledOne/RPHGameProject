extends Control

@export var bus_index : int = 0

@onready var slider : HSlider = $HSlider
@onready var label_value : Label = $LabelValue

func _ready() -> void:
	var volume_linear = AudioServer.get_bus_volume_linear(bus_index)
	slider.value = volume_linear * 100
	$LabelValue/LabelName.text = AudioServer.get_bus_name(0)

func _on_h_slider_value_changed(value: float) -> void:
	label_value.text = str(int(value))
	var new_volume = value / 100
	AudioServer.set_bus_volume_linear(bus_index, new_volume)
	

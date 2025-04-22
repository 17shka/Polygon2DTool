@tool
extends HBoxContainer

@onready var spin_box: SpinBox = $VBoxContainer/SpinBox
@onready var h_slider: HSlider = $VBoxContainer/HSlider

signal value_changed(value: float)

func _on_spin_box_value_changed(value: float) -> void:
	h_slider.value = value
	emit_signal("value_changed", value)

func _on_h_slider_value_changed(value: float) -> void:
	spin_box.value = value
	emit_signal("value_changed", value)

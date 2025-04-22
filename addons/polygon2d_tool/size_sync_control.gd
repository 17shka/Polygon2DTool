@tool
extends HBoxContainer

@onready var sync: CheckBox = $HBoxContainer/Sync
@onready var x: SpinBox = $HBoxContainer/VBoxContainer/X
@onready var y: SpinBox = $HBoxContainer/VBoxContainer/Y

signal values_changed(value: Vector2)

func _emit_values_changed() -> void:
	var value = Vector2(x.value, y.value)
	emit_signal("values_changed", value)

func _on_sync_toggled(checked: bool) -> void:
	if sync.button_pressed:
		var max_value = max(x.value, y.value)
		_on_value_changed(max_value)

func _on_value_changed(value: float) -> void:
	if sync.button_pressed:
		x.value = value
		y.value = value
	_emit_values_changed()

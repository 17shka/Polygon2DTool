@tool
extends Button

@export var target_buttons: Array[SpinBox]
var initial_values: Dictionary = {}

func _init() -> void:
	text = "⟲"
	
func _ready() -> void:
	pressed.connect(_on_pressed)

	for spin_box in target_buttons:
		if spin_box:
			initial_values[spin_box] = spin_box.value

			if spin_box.has_signal("value_changed"):
				spin_box.value_changed.connect(_on_target_value_changed.bind(spin_box))

	update()

func update() -> void:
	var should_show := false
	
	for spin_box in target_buttons:
		if spin_box and initial_values.has(spin_box):
			if spin_box.value != initial_values[spin_box]:
				should_show = true
				break
	
	visible = should_show

func _on_target_value_changed(_value: float, spin_box: SpinBox) -> void:
	update()

func _on_pressed() -> void:
	for spin_box in target_buttons:
		if spin_box and initial_values.has(spin_box):
			spin_box.value = initial_values[spin_box]

	hide()

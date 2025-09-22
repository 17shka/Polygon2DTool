@tool
extends HBoxContainer

signal value_changed(value: Array[float])

var spin_boxes: Array[SpinBox] = []
var sliders: Array[HSlider] = []
var sync_checkbox: CheckBox
var controls_container: Container
const Arity = preload("uid://bl4x3pamvmaag")

@export var text: String = "Text":
	set(value):
		text = value
		$HBoxContainer/Label.text = value

@export var arity: Array[Arity] = []:
	set(value):
		if value.size() > 0:
			value[-1] = value[-1] if value[-1] is Arity else Arity.new()
		arity = value
		setup_controls()

func _ready() -> void:
	setup_controls()

func setup_controls() -> void:
	if !is_inside_tree():
		return
	
	clear_dynamic_controls()
	if arity.is_empty():
		return
	create_main_container()
	create_controls()
	
	update_values()
	update_reset_button_visibility()

func clear_dynamic_controls() -> void:
	if controls_container:
		controls_container.queue_free()
	
	spin_boxes.clear()
	sliders.clear()
	sync_checkbox = null
	controls_container = null

func create_main_container() -> void:
	if arity.size() == 1:
		controls_container = create_vbox_container()
	else:
		var hbox = HBoxContainer.new()
		hbox.add_child(create_vbox_container())
		controls_container = hbox
	
	controls_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(controls_container)

func create_vbox_container() -> VBoxContainer:
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return vbox

func create_controls() -> void:
	for i in range(arity.size()):
		var item = arity[i]
		var spin_box = SpinBox.new()
		spin_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		spin_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
		spin_box.value_changed.connect(_on_value_changed.bind(i))
		spin_box.select_all_on_focus = true
		
		if i < arity.size():
			var i_item = arity[i]
			spin_box.prefix = i_item.prefix
			spin_box.suffix = i_item.suffix
			spin_box.min_value = i_item.min_value
			spin_box.max_value = i_item.max_value
			spin_box.step = i_item.step
			spin_box.value = i_item.default_value
		
		spin_boxes.append(spin_box)
		
		if arity.size() == 1:
			controls_container.add_child(spin_box)
			if needs_slider(item):
				var slider = HSlider.new()
				slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				slider.value_changed.connect(_on_slider_changed.bind(i))
				
				if i < arity.size():
					var i_item = arity[i]
					slider.min_value = i_item.min_value
					slider.max_value = i_item.max_value
					slider.step = i_item.step
					slider.value = i_item.default_value
				
				controls_container.add_child(slider)
				sliders.append(slider)
		else:
			var vbox = controls_container.get_child(0) as VBoxContainer
			if vbox:
				vbox.add_child(spin_box)
	
	if arity.size() > 1:
		sync_checkbox = CheckBox.new()
		sync_checkbox.toggled.connect(_on_sync_toggled)
		controls_container.add_child(sync_checkbox)

func needs_slider(item: Arity) -> bool:
	return item.step != int(item.step)

func update_values() -> void:
	%Label.text = text
	for i in range(spin_boxes.size()):
		if i >= arity.size():
			continue
		
		var value = arity[i].default_value
		spin_boxes[i].set_value_no_signal(value)
		
		if i < sliders.size():
			sliders[i].set_value_no_signal(value)

func _on_value_changed(value: float, index: int) -> void:
	if sync_checkbox and sync_checkbox.button_pressed:
		sync_all_values(value)
	else:
		update_control_value(index, value)
	
	emit_current_values()
	update_reset_button_visibility()

func sync_all_values(value: float) -> void:
	for spin_box in spin_boxes:
		spin_box.set_value_no_signal(value)
	for slider in sliders:
		slider.set_value_no_signal(value)

func update_control_value(index: int, value: float) -> void:
	spin_boxes[index].set_value_no_signal(value)
	if index < sliders.size():
		sliders[index].set_value_no_signal(value)

func _on_slider_changed(value: float, index: int) -> void:
	if index < spin_boxes.size():
		spin_boxes[index].set_value_no_signal(value)
		_on_value_changed(value, index)

func _on_sync_toggled(checked: bool) -> void:
	if checked and spin_boxes.size() > 0:
		sync_all_values(spin_boxes[0].value)
		emit_current_values()
	update_reset_button_visibility()

func _on_reset_button_pressed() -> void:
	reset_to_default_values()
	emit_current_values()
	update_reset_button_visibility()

func reset_to_default_values() -> void:
	for i in range(spin_boxes.size()):
		if i >= arity.size():
			continue
		
		var default_value = arity[i].default_value
		spin_boxes[i].set_value_no_signal(default_value)
		if i < sliders.size():
			sliders[i].set_value_no_signal(default_value)

func emit_current_values() -> void:
	var current_values: Array[float] = []
	for spin_box in spin_boxes:
		current_values.append(spin_box.value)
	value_changed.emit(current_values)

func update_reset_button_visibility() -> void:
	%ResetButton.visible = !is_at_default_values()

func is_at_default_values() -> bool:
	for i in range(spin_boxes.size()):
		if i >= arity.size():
			continue
		if spin_boxes[i].value != arity[i].default_value:
			return false
	return true

func set_value(value: Array) -> void:
	for i in range(min(value.size(), spin_boxes.size())):
		var i_value = float(value[i])
		spin_boxes[i].value = i_value
		if i < sliders.size():
			sliders[i].value = i_value
	
	emit_current_values()

func get_value(index: int = -1):
	if index == -1:
		return spin_boxes.map(func(spin_box): return spin_box.value)
	elif index >= 0 and index < spin_boxes.size():
		return spin_boxes[index].value
	else:
		return null

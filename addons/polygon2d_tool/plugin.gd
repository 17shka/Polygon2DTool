@tool
extends EditorPlugin

const SCRIPT = preload("uid://bd6ou7yl33fbn")
const ICON = preload("icon.svg")
var tool_instance = SCRIPT.new()

var dock: EditorDock

func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)
	_on_selection_changed()


func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(_on_selection_changed)
	remove()


func add() -> void:
	if not dock:
		dock = EditorDock.new()
		dock.default_slot = EditorPlugin.DOCK_SLOT_RIGHT_BL
		dock.title = "Polygon2DTool"
		dock.dock_icon = ICON

		var panel := VBoxContainer.new()
		var sub_inspector:= EditorInspector.new()
		sub_inspector.edit(tool_instance)
		sub_inspector.size_flags_vertical = Control.SIZE_EXPAND_FILL
		panel.add_child(sub_inspector)

		dock.add_child(panel)

		add_dock(dock)


func remove() -> void:
	if dock:
		remove_dock(dock)
		dock.queue_free()
		dock = null


func _on_selection_changed() -> void:
	var selection := EditorInterface.get_selection().get_selected_nodes()
	var target: Array[Node2D]
	for node in selection:
		if PolygonTool2D.is_supported(node):
			target.append(node)
	if target:
		tool_instance.target = target
		add()
	else:
		remove()

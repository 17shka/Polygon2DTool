@tool
extends EditorPlugin

signal selected_nodes_updated(nodes: Array)

var dock_panel = preload("uid://dpirsfefp0hu3").instantiate()
var dock_icon = preload("uid://b0klot3vkuag6")
var is_panel_added := false 

func _enter_tree():
	get_editor_interface().get_selection().connect("selection_changed", Callable(self, "_on_selection_changed"))
	_on_selection_changed()

	if dock_panel.has_method("update_selected_nodes"):
		selected_nodes_updated.connect(dock_panel.update_selected_nodes)

func _exit_tree():
	if is_panel_added:
		remove_control_from_docks(dock_panel)
		dock_panel.queue_free()

func _on_selection_changed():
	var selection : Array[Node] = get_editor_interface().get_selection().get_selected_nodes()
	var allowed_types := [ "Polygon2D", "CollisionPolygon2D", "LightOccluder2D", "Line2D", "Path2D"]
	
	var filtered_selection := []
	for node in selection:
		if node.get_class() in allowed_types:
			filtered_selection.append(node)

	emit_signal("selected_nodes_updated", filtered_selection)
	
	if filtered_selection.size() > 0:
		if not is_panel_added:
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock_panel)
			set_dock_tab_icon(dock_panel, dock_icon)
			is_panel_added = true
	else:
		if is_panel_added:
			remove_control_from_docks(dock_panel)
			is_panel_added = false

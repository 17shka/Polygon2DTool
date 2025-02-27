@tool
extends EditorPlugin

signal selected_nodes_updated(nodes: Array)

var dock_panel = preload("res://addons/polygon2d_tool/inspector_panel.tscn").instantiate()
var inspector_plugin = preload("res://addons/polygon2d_tool/inspector_plugin.gd").new()
var is_panel_added: bool = false  # Флаг для отслеживания состояния панели
var dock_icon = preload("icon.svg")

func _enter_tree():
	# Подключаем сигнал для отслеживания изменений выбранного объекта
	get_editor_interface().get_selection().connect("selection_changed", Callable(self, "_on_selection_changed"))
	_on_selection_changed()  # Инициализация при запуске

	# Подключаем сигнал к методу в PanelContainer
	if dock_panel.has_method("update_selected_nodes"):
		selected_nodes_updated.connect(dock_panel.update_selected_nodes)

func _exit_tree():
	# Удаляем панель и плагин, если они были добавлены
	if is_panel_added:
		remove_control_from_docks(dock_panel)
		dock_panel.queue_free()
	remove_inspector_plugin(inspector_plugin)

# Обработчик изменения выбранного объекта
func _on_selection_changed():
	var selection = get_editor_interface().get_selection().get_selected_nodes()
	var allowed_types = ["Line2D", "LightOccluder2D", "CollisionPolygon2D", "Polygon2D"]
	
	var filtered_selection = []
	for node in selection:
		if node.get_class() in allowed_types:
			filtered_selection.append(node)
	
	# Отправляем сигнал с отфильтрованными узлами
	emit_signal("selected_nodes_updated", filtered_selection)
	
	if filtered_selection.size() > 0:
		# Добавляем панель, если она ещё не добавлена
		if not is_panel_added:
			add_inspector_plugin(inspector_plugin)
			add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock_panel)
			# Устанавливаем иконку для вкладки панели
			set_dock_tab_icon(dock_panel, dock_icon)
			is_panel_added = true
	else:
		# Убираем панель, если она добавлена
		if is_panel_added:
			remove_control_from_docks(dock_panel)
			is_panel_added = false

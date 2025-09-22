@tool
extends PanelContainer

var selected_nodes: Array = []
var copied_polygons_list: Array[PackedVector2Array]

var p_size: Vector2 = Vector2(64, 64)
var outer_sides: int = 32
var inter_sides: int = outer_sides
var outer_ratio: float = 100
var inter_ratio: float = outer_ratio
var rotate: float = 360
var angle_degrees: float = 360
var internal_margin: float = 0

func _ready() -> void:
	_set_inter_nodes_visible(true if internal_margin > 0 else false)


func update_polygon():
	if %CustomInter.button_pressed == false:
		inter_sides = outer_sides
		inter_ratio = outer_ratio
		
	var polygon = PolygonTool.create_polygon(p_size, outer_sides, outer_ratio, rotate, angle_degrees, internal_margin, inter_sides, inter_ratio)
	PolygonTool.update_polygon(selected_nodes, polygon)

func _on_update_pressed() -> void:
	update_polygon()

func _on_copy_pressed() -> void:
	copied_polygons_list.clear()
	
	for node in selected_nodes:
		if node is Polygon2D:
			copied_polygons_list.append(node.polygon)
		elif node is CollisionPolygon2D:
			copied_polygons_list.append(node.polygon)
		elif node is LightOccluder2D:
			copied_polygons_list.append(node.occluder.polygon)
		elif node is Line2D:
			copied_polygons_list.append(node.points)
		elif node is Path2D:
			# Конвертируем точки кривой в PackedVector2Array
			var points := PackedVector2Array()
			for i in node.curve.get_point_count():
				points.append(node.curve.get_point_position(i))
			copied_polygons_list.append(points)

func _on_paste_pressed() -> void:
	var data_index := 0
	
	for node in selected_nodes:
		if data_index >= copied_polygons_list.size():
			break  # Прекращаем если данные закончились
		
		var points: PackedVector2Array = copied_polygons_list[data_index]
		
		if node is Polygon2D:
			node.polygon = points
			data_index += 1
		elif node is CollisionPolygon2D:
			node.polygon = points
			data_index += 1
		elif node is LightOccluder2D:
			if node.occluder == null:
				node.occluder = OccluderPolygon2D.new()
			node.occluder.polygon = points
			data_index += 1
		elif node is Line2D:
			node.points = points
			data_index += 1
		elif node is Path2D:
			node.curve = Curve2D.new()
			for point in points:
				node.curve.add_point(point)
			data_index += 1

func update_selected_nodes(nodes: Array) -> void:
	selected_nodes = nodes

func _on_size_value_changed(value: Array[float]) -> void:
	p_size.x = value[0]
	p_size.y = value[1]
	update_polygon()

func _on_outer_sides_value_changed(value: Array[float]) -> void:
	outer_sides = value[0]
	update_polygon()

func _on_inter_sides_value_changed(value: Array[float]) -> void:
	inter_sides = value[0]
	update_polygon()
func _on_outer_ratio_value_changed(value: Array[float]) -> void:
	outer_ratio = value[0]
	update_polygon()

func _on_inter_ratio_value_changed(value: Array[float]) -> void:
	inter_ratio = value[0]
	update_polygon()

func _on_rotate_value_changed(value: Array[float]) -> void:
	rotate = value[0]
	update_polygon()

func _on_angle_degrees_value_changed(value: Array[float]) -> void:
	angle_degrees = value[0]
	update_polygon()

func _on_internal_margin_value_changed(value: Array[float]) -> void:
	internal_margin = value[0]
	if %CustomInter.button_pressed:
		_set_inter_nodes_visible(value[0] > 0)
	update_polygon()

func _on_custom_inter_toggled(toggled_on: bool) -> void:
	if %InternalMargin.get_value(0) > 0 and toggled_on:
		%InterSides.set_value([outer_sides])
		%InterRatio.set_value([outer_ratio])

	if internal_margin > 0:
		_set_inter_nodes_visible(toggled_on)

func _set_inter_nodes_visible(visible: bool) -> void:
	for i in [%InterSides, %InterRatio]:
		i.visible = visible

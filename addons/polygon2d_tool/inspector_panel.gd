@tool
extends PanelContainer

var selected_nodes: Array = []
var dimensions: Vector2 = Vector2(64, 64)
var sides: int = 32
var angle_degrees: float = 360
var ratio: float = 100
var internal_margin: float
var rotate: float = 360

func update_selected_nodes(nodes: Array) -> void:
	selected_nodes = nodes
func _on_size_values_changed(value: Vector2) -> void:
	dimensions = value
	update_polygon()
func _on_sides_value_changed(value: int) -> void:
	sides = value
	update_polygon()
func _on_angle_degrees_value_changed(value: float) -> void:
	angle_degrees = value
	update_polygon()
func _on_ratio_value_changed(value: float) -> void:
	ratio = value
	update_polygon()
func _on_internal_margin_value_changed(value: float) -> void:
	internal_margin = value
	update_polygon()
func _on_rotate_value_changed(value: float) -> void:
	rotate = value
	update_polygon()

func update_polygon():
	var points: Array = get_points()

	for target_item in selected_nodes:
		update_target_polygon(target_item, points)

func update_target_polygon(target_item: Node2D, points: Array) -> void:
	if target_item is Polygon2D or target_item is CollisionPolygon2D:
		target_item.polygon = points
		if target_item is Polygon2DPlus:
			target_item._update_stroke()
	elif target_item is LightOccluder2D:
		if not target_item.occluder:
			target_item.occluder = OccluderPolygon2D.new()
		target_item.occluder.polygon = points
	elif target_item is Line2D:
		target_item.points = points

func get_points() -> Array:
	var points = generate_polygon_points(dimensions, sides, ratio, angle_degrees)

	if internal_margin > 0:
		var inner_size = dimensions * (internal_margin / 100)
		var inner_ratio = ratio
		var inner_points = generate_polygon_points(inner_size, sides, inner_ratio, angle_degrees)
		inner_points.reverse()
		points.append_array(inner_points)

	elif angle_degrees != 360:
		points.append(Vector2.ZERO)

	return points

func generate_polygon_points(p_size: Vector2, p_sides: int, p_ratio: float, p_angle_degrees: float) -> Array:
	var points = []
	var angle_step = deg_to_rad(p_angle_degrees) / p_sides
	var rotation_rad = deg_to_rad(rotate)

	var count = p_sides + 1

	for i in range(count):
		var angle = i * angle_step + rotation_rad
		var point = Vector2(cos(angle), sin(angle)) * p_size
		points.append(point)

		if p_ratio < 100 and i < count - 1:
			var next_angle = (i + 1) * angle_step + rotation_rad
			var dir1 = Vector2(cos(angle), sin(angle))
			var dir2 = Vector2(cos(next_angle), sin(next_angle))
			var mid_point = (dir1 + dir2) * 0.5 * (p_ratio / 100.0)
			mid_point *= p_size
			points.append(mid_point)
	
	return points

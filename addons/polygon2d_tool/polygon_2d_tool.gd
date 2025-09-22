
@icon("uid://b0klot3vkuag6")
@tool
class_name PolygonTool
extends Node2D

@export_tool_button("Update") var update_action = update

## Only works with Polygon2D, CollisionPolygon2D, LightOccluder2D, Line2D, Path2D
@export var target: Array[Node2D] = []:
	set(value):
		target = value
		update()
@export_custom(PROPERTY_HINT_LINK, "") var size: Vector2 = Vector2(64, 64):
	set(new_size):
		if size != new_size:
			size = new_size
			update()
@export_range(3, 128) var outer_sides: int = 32:
	set(value):
		outer_sides = value
		update()
@export_range(0.1, 100) var outer_ratio: float = 100:
	set(value):
		if value < internal_margin:
			internal_margin = value - 0.001
		outer_ratio = value
		update()
@export_range(0.0, 360.0, 0.1, "suffix:°") var rotate: float = 0.0:
	set(value):
		rotate = value
		update()
@export_range(1.0, 360.0, 0.1, "suffix:°") var angle_degrees: float = 360:
	set(value):
		angle_degrees = value
		update()
@export_range(0.0, 99.9) var internal_margin: float:
	set(value):
		if value > outer_ratio:
			outer_ratio = value + 0.001
		internal_margin = value
		update()
@export_range(3, 128) var inter_sides: int = 32:
	set(value):
		inter_sides = value
		update()
@export_range(0.1, 100) var inter_ratio: float = 100:
	set(value):
		inter_ratio = value
		update()
func _ready() -> void:
	update()

func update() -> void:
	var polygon = create_polygon(size, outer_sides, outer_ratio, rotate, angle_degrees, internal_margin, inter_sides, inter_ratio)
	update_polygon(target, polygon)

static func update_polygon(targets: Array, points: Array):
	for node in targets:
		if node is Polygon2D or node is CollisionPolygon2D:
			node.polygon = points
		elif node is LightOccluder2D:
			if not node.occluder:
				node.occluder = OccluderPolygon2D.new()
			node.occluder.polygon = points
		elif node is Path2D:
			node.curve = Curve2D.new()
			for i in points.size():
				node.curve.add_point(points[i])

static func create_polygon(
	p_size: Vector2,
	p_outer_sides: int,
	p_outer_ratio: float = 100,
	p_rotate: float = 0,
	p_angle_degrees: float = 360,
	p_internal_margin: float = 0,
	p_inner_sides: int = p_outer_sides,
	p_inner_ratio: float = p_outer_ratio
) -> Array:
	
	var points = create_points(p_size, p_outer_sides, p_outer_ratio, p_rotate, p_angle_degrees)

	if p_internal_margin > 0:
		var inner_size = p_size * (p_internal_margin / 100)
		var inner_points = create_points(inner_size, p_inner_sides, p_inner_ratio, p_rotate, p_angle_degrees)
		inner_points.reverse()
		points.append_array(inner_points)

	elif p_angle_degrees != 360:
		points.append(Vector2.ZERO)

	return points

static func create_points(p_size: Vector2, p_sides: int, p_ratio: float = 100, p_rotate: float = 0, p_angle_degrees: float = 360) -> Array:
	var points: Array[Vector2] = []
	var angle_step = deg_to_rad(p_angle_degrees) / p_sides
	var rotation_rad = deg_to_rad(p_rotate)

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
			points.append(mid_point * p_size)
	
	return points

static func get_area(points: PackedVector2Array) -> float:
	var area := 0.0
	var n = points.size()
	
	if n < 3:
		return 0.0  # Не является многоугольником
	
	for i in range(n):
		var j = (i + 1) % n
		area += points[i].x * points[j].y
		area -= points[j].x * points[i].y
	
	area = abs(area) * 0.5
	
	return area

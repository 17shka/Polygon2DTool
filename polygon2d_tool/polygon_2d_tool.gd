
@icon("icon.svg")
@tool
class_name PolygonTool
extends Node2D

## Only works with Polygon2D, CollisionPolygon2D, LightOccluder2D, Line2D
@export var target: Array[Node2D] = []:
	set(value):
		target = value
		update()
@export_custom(PROPERTY_HINT_LINK, "") var size: Vector2 = Vector2(64, 64):
	set(new_size):
		if size != new_size:
			size = new_size
			update()
@export_range(3, 128) var sides: int = 32:
	set(value):
		sides = value
		update()
@export_range(1.0, 360.0) var angle_degrees: float = 360:
	set(value):
		angle_degrees = value
		update()
@export_range(0.1, 100) var ratio: float = 100:
	set(value):
		ratio = value
		update()
@export_range(0.0, 99.9) var internal_margin: float:
	set(value):
		internal_margin = value
		update()
@export_range(0.0, 360.0) var rotate: float = 0.0:
	set(value):
		rotate = value
		update()

func _ready() -> void:
	update()

func update() -> void:
	var polygon = create_polygon(size, sides, angle_degrees, ratio, internal_margin, rotate)
	update_polygon(target, polygon)

static func update_polygon(targets: Array, points: Array):
	for i in targets:
		if i is Polygon2D or i is CollisionPolygon2D:
			i.polygon = points
		elif i is LightOccluder2D:
			if not i.occluder:
				i.occluder = OccluderPolygon2D.new()
			i.occluder.polygon = points
		elif i is Line2D:
			i.points = points

static func create_polygon(
	p_size: Vector2,
	p_sides: int,
	p_angle_degrees: float = 360,
	p_ratio: float = 100,
	p_internal_margin: float = 0,
	p_rotate: float = 0
) -> Array:
	
	var points = create_points(p_size, p_sides, p_ratio, p_angle_degrees, p_rotate)

	if p_internal_margin > 0:
		var inner_size = p_size * (p_internal_margin / 100)
		var inner_points = create_points(inner_size, p_sides, p_ratio, p_angle_degrees, p_rotate)
		inner_points.reverse()
		points.append_array(inner_points)

	elif p_angle_degrees != 360:
		points.append(Vector2.ZERO)
	
	return points

static func create_points(p_size: Vector2, p_sides: int, p_ratio: float, p_angle_degrees: float, p_rotate: float) -> Array:
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

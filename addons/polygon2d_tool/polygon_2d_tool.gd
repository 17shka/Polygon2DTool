
@icon("icon.svg")
@tool
class_name PolygonTool
extends Node2D

## Only works with Polygon2D, CollisionPolygon2D, LightOccluder2D, Line2D
@export var target: Array[Node2D] = []:
	set(value):
		target = value
		update_polygon()
@export_custom(PROPERTY_HINT_LINK, "") var size: Vector2 = Vector2(64, 64):
	set(new_size):
		if size != new_size:
			size = new_size
			update_polygon()
@export_range(3, 128) var sides: int = 32:
	set(value):
		sides = value
		update_polygon()
@export_range(1.0, 360.0) var angle_degrees: float = 360:
	set(value):
		angle_degrees = value
		update_polygon()
@export_range(0.1, 100) var ratio: float = 100:
	set(value):
		ratio = value
		update_polygon()
@export_range(0.0, 99.9) var internal_margin: float:
	set(value):
		internal_margin = value
		update_polygon()
@export_range(0.0, 360.0) var rotate: float = 0.0:
	set(value):
		rotate = value
		update_polygon()

func _ready():
	update_polygon()

func update_polygon():
	var points: Array = get_points()

	for target_item in target:
		update_target_polygon(target_item, points)

func update_target_polygon(target_item: Node2D, points: Array) -> void:
	if target_item is Polygon2D or target_item is CollisionPolygon2D:
		target_item.polygon = points
	elif target_item is LightOccluder2D:
		if not target_item.occluder:
			target_item.occluder = OccluderPolygon2D.new()
		target_item.occluder.polygon = points
	elif target_item is Line2D:
		target_item.points = points

func get_points() -> Array:
	var points = generate_polygon_points(size, sides, ratio, angle_degrees)
	
	if internal_margin > 0:
		var inner_size = size * (internal_margin / 100)
		var inner_points = generate_polygon_points(inner_size, sides, ratio, angle_degrees)
		inner_points.reverse()
		points.append_array(inner_points)
	
	elif angle_degrees != 360:
		points.append(Vector2.ZERO)
	
	return points

func generate_polygon_points(p_size: Vector2, p_sides: int, p_ratio: float, p_angle_degrees: float) -> Array:
	var points = []
	var angle_step = deg_to_rad(p_angle_degrees) / p_sides
	var rotation_rad = deg_to_rad(rotate)
	
	if angle_degrees != 360 or internal_margin != 0:
		p_sides += 1
	
	for i in range(p_sides):
		var angle = i * angle_step + rotation_rad
		var point = Vector2(cos(angle), sin(angle)) * p_size
		points.append(point)

		if p_ratio < 100 and i < p_sides:
			var next_angle = (i + 1) * angle_step + rotation_rad
			var mid_point = (Vector2(cos(angle), sin(angle)) + Vector2(cos(next_angle), sin(next_angle)))
			mid_point = mid_point * (p_size * 0.5) * (p_ratio / 100)
			points.append(mid_point)
	
	return points

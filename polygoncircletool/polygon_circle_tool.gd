@icon("icon.svg")
@tool
class_name PolygonCircleTool
extends Node2D

## Only works with Polygon2D, CollisionPolygon2D, LightOccluder2D
@export var target: Array[Node2D] = []:
	set = set_target
@export var size := Vector2(64, 64): set = set_size
@export_range(3, 128) var sides: int = 32: set = set_sides

func set_size(p_size: Vector2) -> void:
	size = p_size
	update_polygon()

func set_sides(p_sides: int) -> void:
	sides = p_sides
	update_polygon()

func set_target(new_target: Array) -> void:
	target = new_target
	update_polygon()

func _ready():
	update_polygon()

func update_polygon():
	var points: Array = get_points()
	
	for target_item in target:
		if target_item is Polygon2D:
			target_item.polygon = points
		elif target_item is CollisionPolygon2D:
			target_item.polygon = points
		elif target_item is LightOccluder2D:
			if not target_item.occluder:
				target_item.occluder = OccluderPolygon2D.new()
			target_item.occluder.polygon = points

func get_points() -> Array:
	var points = []
	var angle_step = 2 * PI / sides
	for i in range(sides):
		var angle = i * angle_step
		var point = Vector2(cos(angle), sin(angle)) * size
		points.append(point)
	return points

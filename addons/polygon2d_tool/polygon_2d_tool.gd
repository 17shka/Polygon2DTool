@icon("icon.svg")
@tool
class_name PolygonTool2D

@export_tool_button("Update", "Reload") var update_action: Callable = update

var target: Array[Node2D] = []

enum Type {POLYGON, RECTANGLE}
@export var type: Type = Type.RECTANGLE:
	set(value):
		type = value
		notify_property_list_changed()
		update()

@export_custom(PROPERTY_HINT_LINK, "suffix:px") var size: Vector2 = Vector2(64, 64):
	set(value):
		size = value
		update()

@export_range(3, 128, 1, "or_greater") var sides: int = 3:
	set(value):
		sides = value
		update()

@export_range(0.1, 360.0, 0.1) var angle_degrees: float = 360.0:
	set(value):
		angle_degrees = value
		update()

@export_range(0.1, 100, 0.1, "suffix:%") var ratio: float = 100.0:
	set(value):
		ratio = value
		update()

@export_range(0.0, 360.0, 0.1, "or_less", "or_greater", "radians_as_degrees") var rotate: float = 0.0:
	set(value):
		rotate = value
		update()

@export_subgroup("Rounding")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var enable_rounding: bool = false:
	set(value):
		enable_rounding = value
		update()

@export_range(0, 64, 0.1, "or_greater") var rounding: float = 12:
	set(value):
		rounding = value
		update()

@export_range(2, 64, 1, "or_greater") var rounding_quality: int = 8:
	set(value):
		rounding_quality = value
		update()

@export_group("Internal")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var enable_internal: bool = false:
	set(value):
		enable_internal = value
		update()

@export_range(0.0, 99.9, 0.1, "suffix:%") var internal_margin: float = 25:
	set(value):
		internal_margin = value
		update()

@export var sync_internal_params: bool = true:
	set(value):
		sync_internal_params = value
		notify_property_list_changed()
		update()

@export var auto_params: bool = false:
	set(value):
		auto_params = value
		notify_property_list_changed()
		update()

@export_range(3, 128, 1, "or_greater") var internal_sides: int = 3:
	set(value):
		internal_sides = value
		update()

@export_range(0.1, 100, 0.1, "suffix:%") var internal_ratio: float = 100.0:
	set(value):
		internal_ratio = value
		update()

@export_range(0.0, 360.0, 0.1, "or_less", "or_greater", "radians_as_degrees") var internal_rotate: float = 0.0:
	set(value):
		internal_rotate = value
		update()

@export_subgroup("Internal rounding")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var enable_internal_rounding: bool = false:
	set(value):
		enable_internal_rounding = value
		update()

@export_range(0, 64, 0.1, "or_greater") var internal_rounding: float = 12:
	set(value):
		internal_rounding = value
		update()

@export_range(2, 64, 1, "or_greater") var internal_rounding_quality: int = 8:
	set(value):
		internal_rounding_quality = value
		update()


func _validate_property(property: Dictionary) -> void:
	if type == Type.RECTANGLE:
		if property.name in ["sides", "angle_degrees", "ratio", "internal_sides", "internal_ratio"]:
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if (sync_internal_params or auto_params) and property.name == "internal_sides":
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if sync_internal_params and property.name in ["internal_ratio", "internal_rotate", "internal_rounding_quality"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if auto_params and property.name in ["internal_rounding", "internal_rounding_quality"]:
		property.usage = PROPERTY_USAGE_NO_EDITOR


func update() -> void:
	var margin_factor: float = internal_margin / 100.0
	var actual_int_rot: float = rotate if sync_internal_params else internal_rotate
	
	var r_ext: float = rounding if enable_rounding else 0.0
	var r_int: float = 0.0
	var q_int: int = internal_rounding_quality
	
	if enable_internal_rounding:
		if auto_params:
			r_int = r_ext * margin_factor
			q_int = max(2, int(rounding_quality * margin_factor))
		elif sync_internal_params:
			r_int = r_ext
			q_int = rounding_quality
		else:
			r_int = internal_rounding
	
	# Расчет сторон
	var actual_int_sides: int = internal_sides
	if auto_params:
		actual_int_sides = max(3, int(sides * margin_factor))
	elif sync_internal_params:
		actual_int_sides = sides
		
	var actual_int_ratio: float = ratio if sync_internal_params else internal_ratio
	
	var points: PackedVector2Array
	if type == Type.RECTANGLE:
		points = create_rectangle_complex(size, rotate, actual_int_rot, r_ext, rounding_quality, internal_margin, r_int, q_int, enable_internal)
	else:
		points = create_polygon(size, sides, actual_int_sides, angle_degrees, ratio, actual_int_ratio, internal_margin, rotate, actual_int_rot, r_ext, rounding_quality, r_int, q_int, enable_internal)
	update_polygon(target, points)


static func bridge_polygons(p_ext: PackedVector2Array, p_int: PackedVector2Array) -> PackedVector2Array:
	if p_ext.is_empty() or p_int.is_empty(): return p_ext
	
	var best_ext_idx: int = 0
	var best_int_idx: int = 0
	var min_dist: float = INF

	for i in range(p_ext.size()):
		for j in range(p_int.size()):
			var d: float = p_ext[i].distance_squared_to(p_int[j])
			if d < min_dist:
				min_dist = d
				best_ext_idx = i
				best_int_idx = j
	
	var res: PackedVector2Array = []

	for i in range(p_ext.size()):
		res.append(p_ext[(best_ext_idx + i) % p_ext.size()])

	res.append(p_ext[best_ext_idx]) 

	for i in range(p_int.size()):
		res.append(p_int[(best_int_idx + i) % p_int.size()])
	res.append(p_int[best_int_idx])
	
	return res


static func create_rectangle_complex(p_size: Vector2, p_rotate: float, p_int_rotate: float, p_rounding: float, p_quality: int, p_margin: float, p_int_rounding: float, p_int_quality: int, p_use_internal: bool) -> PackedVector2Array:
	var half: Vector2 = p_size / 2.0
	var ext_raw: PackedVector2Array = [Vector2(-half.x, -half.y), Vector2(half.x, -half.y), Vector2(half.x, half.y), Vector2(-half.x, half.y)]
	var ext_rounded: PackedVector2Array = apply_rounding(ext_raw, p_rounding, p_quality, true)
	for i in range(ext_rounded.size()): ext_rounded[i] = ext_rounded[i].rotated(p_rotate)
	
	if p_use_internal and p_margin > 0:
		var i_half: Vector2 = half * (p_margin / 100.0)
		var int_raw: PackedVector2Array = [Vector2(-i_half.x, -i_half.y), Vector2(i_half.x, -i_half.y), Vector2(i_half.x, i_half.y), Vector2(-i_half.x, i_half.y)]
		int_raw.reverse()
		var int_rounded: PackedVector2Array = apply_rounding(int_raw, p_int_rounding, p_int_quality, true)
		for i in range(int_rounded.size()): int_rounded[i] = int_rounded[i].rotated(p_int_rotate)
		return bridge_polygons(ext_rounded, int_rounded)
	return ext_rounded


static func create_polygon(p_size: Vector2, p_ext_sides: int, p_int_sides: int, p_angle: float, p_ratio: float, p_int_ratio: float, p_margin: float, p_rotate: float, p_int_rotate: float, p_rounding: float, p_quality: int, p_int_rounding: float, p_int_quality: int, p_use_internal: bool) -> PackedVector2Array:
	var is_closed: bool = p_angle >= 360.0
	var ext_raw: PackedVector2Array = create_raw_points(p_size, p_ext_sides, p_ratio, p_angle, p_rotate)
	var ext_rounded: PackedVector2Array = apply_rounding(ext_raw, p_rounding, p_quality, is_closed)
	
	if p_use_internal and p_margin > 0:
		var int_raw: PackedVector2Array = create_raw_points(p_size * (p_margin / 100.0), p_int_sides, p_int_ratio, p_angle, p_int_rotate)
		int_raw.reverse()
		var int_rounded: PackedVector2Array = apply_rounding(int_raw, p_int_rounding, p_int_quality, is_closed)
		if is_closed: return bridge_polygons(ext_rounded, int_rounded)
		var combined: PackedVector2Array = ext_rounded
		combined.append_array(int_rounded)
		return combined
	elif not is_closed:
		ext_rounded.append(Vector2.ZERO)
	return ext_rounded


static func create_raw_points(p_size: Vector2, p_sides: int, p_ratio: float, p_angle: float, p_rotate: float) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	var step: float = deg_to_rad(p_angle) / p_sides
	var offset: float = -PI/2.0
	var count: int = p_sides + 1 if p_angle < 360.0 else p_sides
	for i in range(count):
		var a: float = i * step + p_rotate + offset
		pts.append(Vector2(cos(a), sin(a)) * p_size)
		if p_ratio < 100.0 and i < p_sides:
			var ma: float = (i + 0.5) * step + p_rotate + offset
			pts.append(Vector2(cos(ma), sin(ma)) * p_size * (p_ratio / 100.0))
	return pts


static func apply_rounding(p_points: PackedVector2Array, p_radius: float, p_quality: int, p_closed: bool) -> PackedVector2Array:
	if p_radius <= 0 or p_points.size() < 3: return p_points
	var result: PackedVector2Array = []
	var l: int = p_points.size()
	for i in range(l):
		var p2: Vector2 = p_points[i]
		if not p_closed and (i == 0 or i == l - 1):
			result.append(p2)
			continue
		var p1: Vector2 = p_points[(i - 1 + l) % l]
		var p3: Vector2 = p_points[(i + 1) % l]
		var v1: Vector2 = (p1 - p2).normalized()
		var v2: Vector2 = (p3 - p2).normalized()
		var angle: float = v1.angle_to(v2)
		if abs(angle) < 0.001 or abs(abs(angle) - PI) < 0.001:
			result.append(p2)
			continue
		var half_angle: float = abs(angle) / 2.0
		var max_dist: float = min(p2.distance_to(p1), p2.distance_to(p3)) * 0.49
		var actual_radius: float = min(p_radius, max_dist * tan(half_angle))
		var needed_dist: float = actual_radius / tan(half_angle)
		var center: Vector2 = p2 + (v1 + v2).normalized() * (actual_radius / sin(half_angle))
		var start_a: float = (p2 + v1 * needed_dist - center).angle()
		var end_a: float = (p2 + v2 * needed_dist - center).angle()
		var diff: float = fposmod(end_a - start_a + PI, TAU) - PI
		for j in range(p_quality + 1):
			var a: float = start_a + diff * (float(j) / p_quality)
			result.append(center + Vector2(cos(a), sin(a)) * actual_radius)
	return result


static func update_polygon(targets: Array[Node2D], points: PackedVector2Array) -> void:
	for node in targets:
		if node is Polygon2D or node is CollisionPolygon2D:
			node.polygon = points
		elif node is CollisionShape2D:
			if not node.shape:
				node.shape = ConvexPolygonShape2D.new()
			if node.shape is ConvexPolygonShape2D:
				node.shape.points = points
		elif node is LightOccluder2D:
			if not node.occluder:
				node.occluder = OccluderPolygon2D.new()
			node.occluder.polygon = points
		elif node is Line2D:
			node.points = points
		elif node is Path2D:
			node.curve = Curve2D.new()
			for i in points.size():
				node.curve.add_point(points[i])
			if points.size() > 0:
				node.curve.add_point(points[0])
		elif node is NavigationObstacle2D:
			node.vertices = points
		elif node is CPUParticles2D:
			node.emission_points = points
		elif node is NavigationRegion2D:
			if not node.navigation_polygon:
				node.navigation_polygon = NavigationPolygon.new()
			if node.navigation_polygon.get_outline_count():
				node.navigation_polygon.set_outline(0, points)
			else:
				node.navigation_polygon.add_outline(points)


static func is_supported(node: Node) -> bool:
	return node is Polygon2D or node is CollisionPolygon2D or \
		   node is Line2D or node is CollisionShape2D or \
		   node is LightOccluder2D or node is Path2D or \
		   node is NavigationObstacle2D or node is NavigationRegion2D or \
		   node is CPUParticles2D

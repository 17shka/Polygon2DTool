@tool
extends PanelContainer

var selected_nodes: Array = []
var p_size: Vector2 = Vector2(64, 64)
var sides: int = 32
var angle_degrees: float = 360
var ratio: float = 100
var internal_margin: float
var rotate: float = 360

func update_selected_nodes(nodes: Array) -> void:
	selected_nodes = nodes
func _on_size_values_changed(value: Vector2) -> void:
	p_size = value
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
	var polygon = PolygonTool.create_polygon(p_size, sides, angle_degrees, ratio, internal_margin, rotate)
	PolygonTool.update_polygon(selected_nodes, polygon)

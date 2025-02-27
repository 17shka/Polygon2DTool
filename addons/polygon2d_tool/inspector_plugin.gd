@tool
extends EditorInspectorPlugin
#
#func _can_handle(object):
	#return (object is Polygon2D or 
			#object is CollisionPolygon2D or 
			#object is LightOccluder2D or 
			#object is Line2D)
#
#func _parse_begin(object):
	#var panel = preload("res://addons/polygon2d_tool/inspector_panel.tscn").instantiate()
	#panel.target = object
	#add_custom_control(panel)

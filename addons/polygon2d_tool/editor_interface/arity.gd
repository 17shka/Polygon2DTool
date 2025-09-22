extends Resource

@export_category("SpinBox")
@export var prefix: String
@export var suffix: String
	
@export_category("Range")
@export var min_value: float = 0
@export var max_value: float = 100
@export var step: float = 1
@export var default_value: float

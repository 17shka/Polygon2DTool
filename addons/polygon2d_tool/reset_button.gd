@tool
class_name ResetButton
extends Button

# Изменяем на массив SpinBox'ов
@export var target_buttons: Array[SpinBox]
var initial_values: Dictionary = {}  # Будем хранить начальные значения по индексам

func _init() -> void:
	text = "⟲"
	
func _ready() -> void:
	pressed.connect(_on_pressed)
	
	# Инициализируем для всех целевых SpinBox'ов
	for spin_box in target_buttons:
		if spin_box:
			# Сохраняем начальное значение с привязкой к самому объекту
			initial_values[spin_box] = spin_box.value
			
			# Подключаем сигналы изменения значения
			if spin_box.has_signal("value_changed"):
				spin_box.value_changed.connect(_on_target_value_changed.bind(spin_box))
	
	# Первоначальное обновление видимости
	update_visibility()

# Переименовал метод для ясности
func update_visibility() -> void:
	var should_show := false
	
	# Проверяем все SpinBox'ы
	for spin_box in target_buttons:
		if spin_box and initial_values.has(spin_box):
			if spin_box.value != initial_values[spin_box]:
				should_show = true
				break
	
	visible = should_show

# Добавляем параметр spin_box чтобы знать, какой именно изменился
func _on_target_value_changed(_value: float, spin_box: SpinBox) -> void:
	update_visibility()

func _on_pressed() -> void:
	# Сбрасываем все SpinBox'ы к начальным значениям
	for spin_box in target_buttons:
		if spin_box and initial_values.has(spin_box):
			spin_box.value = initial_values[spin_box]
	
	# После сброса скрываем кнопку
	hide()

class_name Health
extends Node

signal max_health_changed(diff: int)
signal health_changed(diff: int)
signal health_depleted()

@export var max_health: int = 100 : set = set_max_health, get = get_max_health
@onready var health: int = max_health : set = set_health, get = get_health

func set_max_health(value: int):
	var clamped_value = 1 if value <= 0 else value
	if not clamped_value == max_health:
		var difference = clamped_value - max_health
		max_health = clamped_value
		max_health_changed.emit(difference)
		if health > max_health:
			var difference2 = health - max_health
			health = max_health
			health_changed.emit(difference2)
		else: if max_health > health:
			health = health+difference
			health_changed.emit(difference)

func get_max_health() -> int:
	return max_health

func set_health(value: int):
	var clamped_value = clampi(value, 0, max_health)
	if not clamped_value == health:
		var difference = clamped_value - health
		health = clamped_value
		health_changed.emit(difference)
		
		if health == 0:
			health_depleted.emit()

func get_health():
	return health

func take_damage(value: int):
	var difference = health - value
	set_health(difference)

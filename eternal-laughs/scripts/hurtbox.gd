class_name Hurtbox
extends Area2D

signal damage_received(damage: int)

func _ready():
	connect("area_entered",_on_area_entered)

func _on_area_entered(area: Area2D):
	if area.is_in_group("attack"):
		if not area.get("damage") == null:
			var damage = area.damage
			damage_received.emit(damage)

func take_damage(damage: int):
	damage_received.emit(damage)

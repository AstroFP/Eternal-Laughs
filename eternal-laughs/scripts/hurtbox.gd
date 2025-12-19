class_name Hurtbox
extends Area2D

signal damage_received(damage: int)

var overlapping_attacks := {}

func _ready():
	connect("area_entered", _on_area_entered)
	connect("area_exited", _on_area_exited)

func _on_area_entered(area: Area2D):
	if area.is_in_group("attack"):
		if area.get("is_continuous") == false:
			if not area.get("damage") == null:
				damage_received.emit(area.damage)
		else:
			overlapping_attacks[area] = true
			if is_instance_valid(area):
				damage_received.emit(area.damage)

func _on_area_exited(area: Area2D):
	overlapping_attacks.erase(area)

func _physics_process(delta):
	for area in overlapping_attacks.keys():
		if not is_instance_valid(area):
			overlapping_attacks.erase(area)
			continue
		damage_received.emit(area.damage)

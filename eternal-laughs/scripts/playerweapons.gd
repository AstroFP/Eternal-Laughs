extends Node
class_name PlayerWeapons

@export var max_weapons := 2
@export var starting_weapons: Array[WeaponDatabase.WeaponID] = []

const WeaponDatabase = preload("res://scripts/Weapons_Database.gd")

var weapons := {}

func _ready():
	for weapon_id in starting_weapons:
		add_weapon(weapon_id, get_parent())

func add_weapon(weapon_id: WeaponDatabase.WeaponID, player: Node2D) -> bool:
	if weapons.has(weapon_id):
		return false
	var weapon_scene: PackedScene = WeaponDatabase.WEAPONS[weapon_id]
	var weapon = weapon_scene.instantiate()
	weapon.player = player
	player.add_child.call_deferred(weapon)
	weapons[weapon_id] = weapon
	return true

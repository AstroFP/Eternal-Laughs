extends Node

enum WeaponID {
	ORBITAL,
	MELEE,
	EXPLOSION,
	GUN,
	BEAM
}

const WEAPONS := {
	WeaponID.ORBITAL: preload("res://scenes/67_orb.tscn"),
	WeaponID.MELEE: preload("res://scenes/bullet_weapon.tscn"),
	WeaponID.EXPLOSION: preload("res://scenes/explosion.tscn"),
	WeaponID.GUN: preload("res://scenes/gun.tscn"),
	WeaponID.BEAM: preload("res://scenes/pepe_blast.tscn")
	}

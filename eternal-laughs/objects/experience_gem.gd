extends Area2D

@export var experience = 1

var sprite_green = preload("res://assets/textures/items/gems/Gem_green.png")
var sprite_blue = preload("res://assets/textures/items/gems/Gem_blue.png")
var sprite_red = preload("res://assets/textures/items/gems/Gem_red.png")

var target = null
var speed = 0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var sound = $Sound_collected

func _ready():
	if experience < 5:
		return
	elif experience < 25:
		sprite.texture = sprite_blue
	else:
		sprite.texture =sprite_red

func _physics_process(delta):
	if target != null:
		global_position = global_position.move_toward(target.global_positionm, speed)
		speed += 2*delta

func collect():
	sound.play
	collision.call_deferred("set","disabled",true)
	sprite.visible = false
	return experience

func _on_sound_collected_finished():
	queue_free()

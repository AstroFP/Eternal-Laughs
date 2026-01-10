extends Node2D

@onready var anim = %BoomAnimation
@onready var hitbox = $Hitbox
@onready var collision = $Hitbox/CollisionShape2D
@export var cooldown = 3.0


func _ready():
	anim.visible = false
	collision.set_deferred("disabled",true)

func _on_timer_timeout() -> void:
	collision.set_deferred("disabled",false)
	anim.visible = true
	anim.play("default")

func _on_animated_sprite_2d_animation_finished() -> void:
	anim.visible = false
	collision.set_deferred("disabled",true)

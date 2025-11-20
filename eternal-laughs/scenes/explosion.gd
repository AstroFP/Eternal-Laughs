extends Area2D

@onready var anim = %BoomAnimation

func _physics_process(delta: float) -> void:
	var enemies_in_range = get_overlapping_bodies()
	for enemy in enemies_in_range:
		if enemy.has_method("take_damage"):
			enemy.take_damage()

func _on_timer_timeout() -> void:
	anim.visible = true
	anim.play("default")


func _on_animated_sprite_2d_animation_finished() -> void:
	anim.visible = false

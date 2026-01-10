extends CharacterBody2D

@export var movement_speed := 20.0
var direction
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy_front_texture: Sprite2D = $Sprite2DEnemyGreenCentiFront
@onready var enemy_side_texture: Sprite2D = $Sprite2DEnemyGreenCentiSide
@onready var enemy_back_texture: Sprite2D = $Sprite2DEnemyGreenCentiBack

@onready var health: Health = $Health

func _on_hurtbox_damage_received(damage: int) -> void:
	health.take_damage(damage)

func _on_health_health_depleted() -> void:
	queue_free()

func _physics_process(_delta: float) -> void:
	direction = global_position.direction_to(player.global_position)
	adjust_texture(direction)
	velocity = direction*movement_speed
	move_and_slide()

func adjust_texture(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		enemy_front_texture.visible = true
		enemy_side_texture.visible = false
		enemy_back_texture.visible = false
		return
	
	enemy_front_texture.visible = false
	enemy_side_texture.visible = false
	enemy_back_texture.visible = false
	# Determine dominant movement direction and show corresponding sprite
	if abs(direction.x) > abs(direction.y):
		enemy_side_texture.visible = true
		enemy_side_texture.flip_h = direction.x < 0
	else:
		if direction.y < 0:
			# Moving up - show back texture
			enemy_back_texture.visible = true
		else:
			# Moving down - show front texture
			enemy_front_texture.visible = true

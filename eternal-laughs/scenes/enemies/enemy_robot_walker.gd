extends CharacterBody2D

@export var movement_speed := 20.0
var direction
@onready var player = get_tree().get_first_node_in_group("player")
@onready var enemy_front_texture: Sprite2D = $Sprite2DEnemyRobotWalkerFront
@onready var enemy_side_texture: Sprite2D = $Sprite2DEnemyRobotWalkerSide
@onready var enemy_back_texture: Sprite2D = $Sprite2DEnemyRobotWalkerBack

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

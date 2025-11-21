extends CharacterBody2D

@export var player_movement_speed := 40.0

@onready var player_front_texture: Sprite2D = $Sprite2DPlayerFront
@onready var player_side_texture: Sprite2D = $Sprite2DPlayerSide
@onready var player_back_texture: Sprite2D = $Sprite2DPlayerBack

func _physics_process(delta: float) -> void:
	movement()

func movement():
	# thanks to this player will not move with left&right / up&down are pressed together
	var x_axis_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_axis_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	var final_movement = Vector2(x_axis_movement,y_axis_movement)
	adjust_texture(final_movement)
	velocity = final_movement.normalized()*player_movement_speed
	move_and_slide()

func adjust_texture(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		player_front_texture.visible = true
		player_side_texture.visible = false
		player_back_texture.visible = false
		return
	
	player_front_texture.visible = false
	player_side_texture.visible = false
	player_back_texture.visible = false
	# Determine dominant movement direction and show corresponding sprite
	if abs(direction.x) > abs(direction.y):
		player_side_texture.visible = true
		player_side_texture.flip_h = direction.x < 0
	else:
		if direction.y < 0:
			# Moving up - show back texture
			player_back_texture.visible = true
			player_back_texture.flip_h = false
		else:
			# Moving down - show front texture
			player_front_texture.visible = true
			player_front_texture.flip_h = false

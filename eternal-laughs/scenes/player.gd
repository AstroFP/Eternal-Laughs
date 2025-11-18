extends CharacterBody2D

var movement_speed := 40.0

func _physics_process(delta: float) -> void:
	movement()

func movement():
	# thanks to this player will not move with left&right / up&down are pressed together
	var x_axis_movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y_axis_movement = Input.get_action_strength("down") - Input.get_action_strength("up")
	var final_movement = Vector2(x_axis_movement,y_axis_movement)
	
	velocity = final_movement.normalized()*movement_speed
	move_and_slide()

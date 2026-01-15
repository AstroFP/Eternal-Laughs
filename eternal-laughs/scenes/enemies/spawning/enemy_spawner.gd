extends Node2D

@export var enemy_type_1: PackedScene # weakest
@export var enemy_type_2: PackedScene # medium
@export var enemy_type_3: PackedScene # strongest

@export var max_enemies := 150
@export var difficulty_step_time := 10 # seconds per difficulty increase

@onready var player = get_tree().get_first_node_in_group("player")

var time := 0
var difficulty := 1
var spawn_timer := 0

func _on_timer_timeout() -> void:
	time += 1
	difficulty = int(time / difficulty_step_time) + 1
	spawn_enemies()

func spawn_enemies() -> void:
	if not can_spawn():
		return
	if spawn_timer > 0:
		spawn_timer -= 1
		return
	spawn_timer = get_spawn_delay()
	for i in get_spawn_count():
		var enemy_scene := get_enemy()
		var enemy := enemy_scene.instantiate()
		enemy.global_position = get_random_position()
		add_child(enemy)

func get_spawn_count() -> int:
	return clamp(1 + difficulty / 2, 1, 15)

func get_spawn_delay() -> int:
	return max(1, 6 - difficulty / 3)

func get_enemy() -> PackedScene:
	# Time-based unlocks (VS style)
	if time < 120:
		return enemy_type_1
	elif time < 300:
		return [enemy_type_1, enemy_type_2].pick_random()
	else:
		return [enemy_type_1, enemy_type_2, enemy_type_3].pick_random()

func can_spawn() -> bool:
	return get_tree().get_nodes_in_group("enemy").size() < max_enemies

func get_random_position() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size * randf_range(1.1, 1.4)
	var top_left: Vector2 = player.global_position - viewport_size / 2.0
	var bottom_right: Vector2 = player.global_position + viewport_size / 2.0
	match ["up", "down", "left", "right"].pick_random():
		"up":
			return Vector2(
				randf_range(top_left.x, bottom_right.x),
				top_left.y
			)
		"down":
			return Vector2(
				randf_range(top_left.x, bottom_right.x),
				bottom_right.y
			)
		"left":
			return Vector2(
				top_left.x,
				randf_range(top_left.y, bottom_right.y)
			)
		"right":
			return Vector2(
				bottom_right.x,
				randf_range(top_left.y, bottom_right.y)
			)
	return player.global_position

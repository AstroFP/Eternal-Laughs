extends Node2D

@export var fire_rate: float = 1.5
@export var damage: int = 10

@onready var player := get_parent()
@onready var beam_hitbox:= $Marker2D/Hitbox
@onready var collision:= %CollisionShape2D
@onready var sprite:= $Marker2D/Hitbox/CollisionShape2D/Sprite2D
@onready var fire_timer:= $Timer

func _ready() -> void:
	collision.disabled = true
	sprite.visible = false
	if beam_hitbox:
		beam_hitbox.body_entered.connect(Callable(self, "_on_body_entered"))
	else:
		push_error("BeamHitbox not found!")
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.autostart = true
	fire_timer.connect("timeout", Callable(self, "fire_beam"))

func _process(delta: float) -> void:
	global_position = player.global_position
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy != null:
		var dir = (nearest_enemy.global_position - global_position)
		if dir.length_squared() > 0:
			rotation = dir.angle()
	else:
		rotation = 0

func fire_beam() -> void:
	# Enable sprite and collision
	sprite.visible = true
	beam_hitbox.monitoring = true
	collision.disabled = false
	await get_tree().create_timer(0.1).timeout
	collision.disabled = true
	beam_hitbox.monitoring = false
	sprite.visible = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)

func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return null
	var nearest: Node2D = null
	var min_dist_sq = INF
	for e in enemies:
		if e == null or not e is Node2D:
			continue
		var dist_sq = global_position.distance_squared_to(e.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest = e
	return nearest

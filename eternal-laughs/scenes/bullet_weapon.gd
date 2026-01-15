extends Node2D

# -----------------------------
# CONFIG
# -----------------------------
@export var swing_arc_deg := 90         # total swing angle
@export var swing_speed := 8.0          # how fast the swing progresses
@export var distance := 32.0            # distance from player

# -----------------------------
# NODES
# -----------------------------
@onready var player := get_parent()
@onready var hitbox:= %Hitbox
@onready var collision:= %CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer

# -----------------------------
# RUNTIME STATE
# -----------------------------
var swing_progress: float = 0.0
var swinging_forward := true
var attacking := false
var target_dir: Vector2 = Vector2.RIGHT  # direction toward nearest enemy

# -----------------------------
# READY
# -----------------------------
func _ready() -> void:
	if collision:
		collision.set_deferred("disabled", true)
	else:
		push_error("CollisionShape2D not found under Hitbox!")

	attack_timer.connect("timeout", Callable(self, "start_attack"))

# -----------------------------
# PROCESS
# -----------------------------
func _process(delta: float) -> void:
	# Update target direction if there are enemies
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy != null:
		target_dir = (nearest_enemy.global_position - player.global_position).normalized()

	# Fallback: no enemies → swing forward (default)
	elif target_dir == Vector2.ZERO:
		target_dir = Vector2.RIGHT

	var base_angle = target_dir.angle()

	# Position weapon in front of the player
	position = Vector2.RIGHT.rotated(base_angle) * distance

	# Update swing rotation if attacking
	if attacking:
		update_swing(delta, base_angle)

# -----------------------------
# ATTACK HANDLING
# -----------------------------
func start_attack() -> void:
	attacking = true
	swing_progress = 0.0
	swinging_forward = true

	# Enable hitbox
	if collision:
		collision.set_deferred("disabled", false)

# -----------------------------
# SWING ROTATION
# -----------------------------
func update_swing(delta: float, base_angle: float) -> void:
	var half_arc = deg_to_rad(swing_arc_deg) / 2.0

	if swinging_forward:
		swing_progress += delta * swing_speed
		if swing_progress >= 1.0:
			swing_progress = 1.0
			swinging_forward = false
	else:
		swing_progress -= delta * swing_speed
		if swing_progress <= 0.0:
			swing_progress = 0.0
			swinging_forward = true
			# Swing finished → disable hitbox
			if collision:
				collision.set_deferred("disabled", true)
			attacking = false

	# Apply rotation
	rotation = base_angle + lerp(-half_arc, half_arc, swing_progress)

# -----------------------------
# HELPER: FIND NEAREST ENEMY
# -----------------------------
func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return null  # no enemies → safe exit
	var nearest: Node2D = null
	var min_dist_sq = INF
	for e in enemies:
		# Safety check: skip if node is deleted or not a Node2D
		if e == null or not e is Node2D:
			continue
		var dist_sq = player.global_position.distance_squared_to(e.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest = e
	return nearest

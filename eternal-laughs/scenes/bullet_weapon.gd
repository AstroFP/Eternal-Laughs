extends Node2D

# -----------------------------
# CONFIG
# -----------------------------
@export var swing_arc_deg: float = 90         # total swing angle
@export var swing_speed: float = 8.0         # how fast the swing progresses
@export var distance: float = 32.0           # distance from player
@export var damage: int = 10                 # damage per swing

# -----------------------------
# NODES
# -----------------------------
@onready var player := get_parent()
@onready var hitbox := %Hitbox
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
	# Disable hitbox initially
	if collision and hitbox:
		collision.set_deferred("disabled", true)
		hitbox.monitoring = false
		hitbox.body_entered.connect(Callable(self, "_on_body_entered"))
	else:
		push_error("Hitbox or CollisionShape2D not found!")

	# Connect timer to trigger attack
	attack_timer.wait_time = 2.0  # attack every 2 seconds
	attack_timer.one_shot = false
	attack_timer.autostart = true
	attack_timer.connect("timeout", Callable(self, "start_attack"))

# -----------------------------
# PROCESS: rotate weapon toward nearest enemy
# -----------------------------
func _process(delta: float) -> void:
	global_position = player.global_position

	# Find nearest enemy
	var nearest_enemy = get_nearest_enemy()
	if nearest_enemy != null:
		target_dir = (nearest_enemy.global_position - player.global_position).normalized()
	elif target_dir == Vector2.ZERO:
		target_dir = Vector2.RIGHT

	var base_angle = target_dir.angle()

	# Position weapon in front of player
	position = Vector2.RIGHT.rotated(base_angle) * distance

	# Update swing if attacking
	if attacking:
		update_swing(delta, base_angle)

# -----------------------------
# ATTACK HANDLER
# -----------------------------
func start_attack() -> void:
	attacking = true
	swing_progress = 0.0
	swinging_forward = true

	# Enable hitbox
	if collision and hitbox:
		collision.set_deferred("disabled", false)
		hitbox.monitoring = true

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
			if collision and hitbox:
				collision.set_deferred("disabled", true)
				hitbox.monitoring = false
			attacking = false

	# Apply rotation
	rotation = base_angle + lerp(-half_arc, half_arc, swing_progress)

# ---------------------------
# HELPER: FIND NEAREST ENEMY
# -----------------------------
func get_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		return null

	var nearest: Node2D = null
	var min_dist_sq = INF

	for e in enemies:
		if e == null or not e is Node2D:
			continue
		var dist_sq = player.global_position.distance_squared_to(e.global_position)
		if dist_sq < min_dist_sq:
			min_dist_sq = dist_sq
			nearest = e

	return nearest

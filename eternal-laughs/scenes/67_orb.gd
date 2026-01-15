extends Node2D
# -----------------------------
# CONFIG
# -----------------------------
@export var radius: float = 64.0          # distance from player
@export var rotation_speed: float = 3.0   # radians per second
@export var clockwise: bool = true       # spin direction

# -----------------------------
# NODES
# -----------------------------
@onready var player := get_parent()
@onready var hitbox: Hitbox = get_node("Hitbox") as Hitbox
@onready var collision: CollisionShape2D = hitbox.get_node("CollisionShape2D") as CollisionShape2D

# -----------------------------
# RUNTIME STATE
# -----------------------------
var angle: float = 0.0  # current angle around player

# -----------------------------
# PROCESS
# -----------------------------
func _process(delta: float) -> void:
	if clockwise:
		angle += rotation_speed * delta
	else:
		angle -= rotation_speed * delta

	# Keep angle in 0..2π
	angle = wrapf(angle, 0, PI * 2)

	# Position orb around player
	position = Vector2.RIGHT.rotated(angle) * radius

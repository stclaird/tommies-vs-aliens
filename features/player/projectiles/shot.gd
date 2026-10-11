extends Area2D

const ROUND_LEFT_TEXTURE := preload("res://features/player/projectiles/303-round-left.png")
const ROUND_RIGHT_TEXTURE := preload("res://features/player/projectiles/303-round-right.png")
const SPEED := 520.0
const LIFETIME := 3.0
const ANIMATION_FPS := 12.0

@onready var sprite: Sprite2D = $Sprite2D

var direction := 1
var remaining_lifetime := LIFETIME
var animation_timer := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position.x += direction * SPEED * delta
	remaining_lifetime -= delta
	if remaining_lifetime <= 0.0:
		queue_free()
		return

	animation_timer += delta
	if animation_timer >= 1.0 / ANIMATION_FPS:
		animation_timer -= 1.0 / ANIMATION_FPS
		sprite.frame = (sprite.frame + 1) % 4

func set_direction(horizontal_direction: int) -> void:
	direction = -1 if horizontal_direction < 0 else 1
	sprite.texture = ROUND_LEFT_TEXTURE if direction < 0 else ROUND_RIGHT_TEXTURE
	sprite.hframes = 4
	sprite.frame = 0

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_hit"):
		body.call("take_hit")
	queue_free()
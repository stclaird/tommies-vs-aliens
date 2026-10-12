extends CharacterBody2D

signal died
  
const WALK_LEFT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-walk-left.png")
const WALK_RIGHT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-walk-right.png")
const STAND_LEFT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-stand-left.png")
const STAND_RIGHT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-stand-right.png")

const PATROL_LEFT := 40.0
const PATROL_RIGHT := 1160.0
const SPAWN_TOP := 80.0
const SPAWN_BOTTOM := 520.0
const WALK_SPEED := 48.0
const WALK_FRAMES := 6
const WALK_FPS := 8.0
const WALK_TIME_MIN := 3.0
const WALK_TIME_MAX := 7.0
const PAUSE_TIME_MIN := 0.8
const PAUSE_TIME_MAX := 2.0

@onready var sprite: Sprite2D = $Sprite2D

var rng := RandomNumberGenerator.new()
var direction := 1
var paused := false
var is_dead := false
var state_timer := 0.0
var frame_timer := 0.0

func _ready() -> void:
	rng.randomize()
	position = Vector2(
		rng.randf_range(PATROL_LEFT, PATROL_RIGHT),
		rng.randf_range(SPAWN_TOP, SPAWN_BOTTOM)
	)
	direction = -1 if rng.randi_range(0, 1) == 0 else 1
	state_timer = rng.randf_range(WALK_TIME_MIN, WALK_TIME_MAX)
	_set_sprite_state(true)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		z_index = roundi(global_position.y)

	if paused:
		state_timer -= delta
		if state_timer <= 0.0:
			paused = false
			state_timer = rng.randf_range(WALK_TIME_MIN, WALK_TIME_MAX)
			_set_sprite_state(true)
		return

	velocity = Vector2(direction * WALK_SPEED, 0.0)
	move_and_slide()

	if is_on_wall():
		direction *= -1
		_set_sprite_state(true)
	elif position.x <= PATROL_LEFT:
		position.x = PATROL_LEFT
		direction = 1
		_set_sprite_state(true)
	elif position.x >= PATROL_RIGHT:
		position.x = PATROL_RIGHT
		direction = -1
		_set_sprite_state(true)

	state_timer -= delta
	if state_timer <= 0.0:
		paused = true
		state_timer = rng.randf_range(PAUSE_TIME_MIN, PAUSE_TIME_MAX)
		velocity = Vector2.ZERO
		_set_sprite_state(false)
		return

	frame_timer += delta
	if frame_timer >= 1.0 / WALK_FPS:
		frame_timer -= 1.0 / WALK_FPS
		sprite.frame = (sprite.frame + 1) % WALK_FRAMES

func take_hit() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	queue_free()

func _set_sprite_state(walking: bool) -> void:
	if walking:
		sprite.texture = WALK_LEFT_TEXTURE if direction < 0 else WALK_RIGHT_TEXTURE
		sprite.hframes = WALK_FRAMES
	else:
		sprite.texture = STAND_LEFT_TEXTURE if direction < 0 else STAND_RIGHT_TEXTURE
		sprite.hframes = 1
	sprite.frame = 0
	frame_timer = 0.0

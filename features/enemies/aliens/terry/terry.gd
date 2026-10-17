extends CharacterBody2D

signal died

@export_range(1, 100, 1) var max_health := 3

const WALK_LEFT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-walk-left.png")
const WALK_RIGHT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-walk-right.png")
const STAND_LEFT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-stand-left.png")
const STAND_RIGHT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-stand-right.png")
const SHOT_LEFT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-shot-left.png")
const SHOT_RIGHT_TEXTURE := preload("res://features/enemies/aliens/sprites/terry-shot-right.png")
const DEAD_LEFT_TEXTURES: Array[Texture2D] = [
	preload("res://features/enemies/aliens/sprites/terry-dead-left.png"),
	preload("res://features/enemies/aliens/sprites/terry-dead-left2.png"),
]
const DEAD_RIGHT_TEXTURES: Array[Texture2D] = [
	preload("res://features/enemies/aliens/sprites/terry-dead-right.png"),
	preload("res://features/enemies/aliens/sprites/terry-dead-right2.png"),
]

const PATROL_LEFT := 40.0
const PATROL_RIGHT := 1160.0
const SPAWN_TOP := 80.0
const SPAWN_BOTTOM := 520.0
const WALK_SPEED := 48.0
const WALK_FRAMES := 6
const WALK_FPS := 8.0
const SHOT_FRAMES := 4
const SHOT_FPS := 12.0
const WALK_TIME_MIN := 3.0
const WALK_TIME_MAX := 7.0
const PAUSE_TIME_MIN := 0.8
const PAUSE_TIME_MAX := 2.0
const DEAD_FRAMES := 9
const DEAD_FPS := 8.0

@onready var sprite: Sprite2D = $Sprite2D

var rng := RandomNumberGenerator.new()
var direction := 1
var paused := false
var is_dead := false
var hit_animation_playing := false
var death_animation_playing := false
var state_timer := 0.0
var frame_timer := 0.0
var current_health := 3

func _ready() -> void:
	rng.randomize()
	current_health = max_health
	position = Vector2(
		rng.randf_range(PATROL_LEFT, PATROL_RIGHT),
		rng.randf_range(SPAWN_TOP, SPAWN_BOTTOM)
	)
	direction = -1 if rng.randi_range(0, 1) == 0 else 1
	state_timer = rng.randf_range(WALK_TIME_MIN, WALK_TIME_MAX)
	_set_sprite_state(true)

func _physics_process(delta: float) -> void:
	if death_animation_playing:
		_advance_death_animation(delta)
		return

	if hit_animation_playing:
		_advance_hit_animation(delta)
		return

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
	current_health -= 1
	if current_health > 0:
		sprite.texture = SHOT_LEFT_TEXTURE if direction < 0 else SHOT_RIGHT_TEXTURE
		sprite.hframes = SHOT_FRAMES
		sprite.frame = 0
		frame_timer = 0.0
		hit_animation_playing = true
		return
	is_dead = true
	var dead_textures := DEAD_LEFT_TEXTURES if direction < 0 else DEAD_RIGHT_TEXTURES
	sprite.texture = dead_textures[rng.randi_range(0, dead_textures.size() - 1)]
	sprite.hframes = DEAD_FRAMES
	sprite.frame = 0
	frame_timer = 0.0
	death_animation_playing = true
	paused = false
	velocity = Vector2.ZERO

func _advance_hit_animation(delta: float) -> void:
	frame_timer += delta
	var frame_duration := 1.0 / SHOT_FPS
	while frame_timer >= frame_duration:
		frame_timer -= frame_duration
		if sprite.frame >= SHOT_FRAMES - 1:
			hit_animation_playing = false
			_set_sprite_state(not paused)
			return
		sprite.frame += 1

func _advance_death_animation(delta: float) -> void:
	frame_timer += delta
	var frame_duration := 1.0 / DEAD_FPS
	while frame_timer >= frame_duration:
		frame_timer -= frame_duration
		if sprite.frame >= DEAD_FRAMES - 1:
			death_animation_playing = false
			died.emit()
			queue_free()
			return
		sprite.frame += 1

func _set_sprite_state(walking: bool) -> void:
	if walking:
		sprite.texture = WALK_LEFT_TEXTURE if direction < 0 else WALK_RIGHT_TEXTURE
		sprite.hframes = WALK_FRAMES
	else:
		sprite.texture = STAND_LEFT_TEXTURE if direction < 0 else STAND_RIGHT_TEXTURE
		sprite.hframes = 1
	sprite.frame = 0
	frame_timer = 0.0

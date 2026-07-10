extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var shower_wall_sprite: Sprite2D = get_node_or_null("../ShowerWall/Sprite2D")

const STAND_RT_TEXTURE := preload("res://graphics/soldier-1-stand-rt-Sheet.png")
const STAND_LT_TEXTURE := preload("res://graphics/soldier-1-stand-lt-Sheet.png")
const WALK_RT_TEXTURE := preload("res://graphics/soldier-1-walk-rt-Sheet.png")
const WALK_LT_TEXTURE := preload("res://graphics/soldier-1-walk-lt-Sheet.png")

const WALK_SPEED := 120.0

const STAND_FRAMES := 6
const STAND_FPS := 8.0
const WALK_FRAMES := 6
const WALK_FPS := 10.0
const FIRST_FRAME_HOLD := 2.0
const REFERENCE_VIEWPORT := Vector2(480.0, 270.0)
const BASE_SPRITE_SCALE := 1.0
const LEVEL_SIZE := Vector2(1280.0, 720.0)
const TOP_PLAY_AREA_INSET := 48.0
const SHOWER_WALL_CUTOFF_LOCAL_Y := 174.0
const PLAYER_FRONT_Z := 10
const PLAYER_BEHIND_Z := 0
const WALL_FRONT_Z := 10
const WALL_BACK_Z := 0

var frame_timer := 0.0
var facing_left := false
var moving := false
var was_moving := false

func _ready() -> void:
	sprite.texture = STAND_RT_TEXTURE
	sprite.hframes = STAND_FRAMES
	sprite.frame = 0
	_update_sprite_scale()
	_clamp_to_level_bounds()
	_update_depth_sorting()
	get_viewport().size_changed.connect(_update_sprite_scale)

func _physics_process(delta: float) -> void:
	var input_dir := _get_movement_input()
	was_moving = moving
	moving = input_dir != Vector2.ZERO

	if was_moving and not moving:
		sprite.frame = 0
		frame_timer = 0.0

	if moving:
		velocity = input_dir * WALK_SPEED

		if input_dir.x < 0.0:
			facing_left = true
		elif input_dir.x > 0.0:
			facing_left = false

		_set_sprite_state(true, facing_left)
	else:
		velocity = Vector2.ZERO
		_set_sprite_state(false, facing_left)

	move_and_slide()
	_clamp_to_level_bounds()
	_update_depth_sorting()

	frame_timer += delta

	while frame_timer >= _get_current_frame_duration():
		frame_timer -= _get_current_frame_duration()
		if moving:
			sprite.frame = (sprite.frame + 1) % WALK_FRAMES
		else:
			sprite.frame = (sprite.frame + 1) % STAND_FRAMES

func _get_current_frame_duration() -> float:
	if moving:
		return 1.0 / WALK_FPS

	if sprite.frame == 0:
		return FIRST_FRAME_HOLD

	return 1.0 / STAND_FPS

func _set_sprite_state(is_walking: bool, is_facing_left: bool) -> void:
	if is_walking:
		sprite.texture = WALK_LT_TEXTURE if is_facing_left else WALK_RT_TEXTURE
		sprite.hframes = WALK_FRAMES
		if sprite.frame >= WALK_FRAMES:
			sprite.frame = 0
	else:
		sprite.texture = STAND_LT_TEXTURE if is_facing_left else STAND_RT_TEXTURE
		sprite.hframes = STAND_FRAMES
		if sprite.frame >= STAND_FRAMES:
			sprite.frame = 0

func _get_movement_input() -> Vector2:
	var x := 0.0
	var y := 0.0

	if Input.is_physical_key_pressed(KEY_A):
		x -= 1.0
	if Input.is_physical_key_pressed(KEY_D):
		x += 1.0
	if Input.is_physical_key_pressed(KEY_W):
		y -= 1.0
	if Input.is_physical_key_pressed(KEY_S):
		y += 1.0

	# Fallback to existing input actions if the project defines them.
	x += Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	y += Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if x == 0.0 and y == 0.0:
		return Vector2.ZERO

	return Vector2(x, y).normalized()

func _update_sprite_scale() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor: float = minf(viewport_size.x / REFERENCE_VIEWPORT.x, viewport_size.y / REFERENCE_VIEWPORT.y)
	var integer_factor: float = maxf(1.0, floorf(scale_factor))
	var final_scale: float = BASE_SPRITE_SCALE * integer_factor
	sprite.scale = Vector2(final_scale, final_scale)
	_clamp_to_level_bounds()

func _clamp_to_level_bounds() -> void:
	var frame_size := Vector2(sprite.texture.get_width() / sprite.hframes, sprite.texture.get_height())
	var half_size := frame_size * sprite.scale * 0.5
	var min_x := half_size.x
	var max_x := LEVEL_SIZE.x - half_size.x
	var min_y := TOP_PLAY_AREA_INSET + half_size.y
	var max_y := LEVEL_SIZE.y - half_size.y

	position.x = clampf(position.x, min_x, max_x)
	position.y = clampf(position.y, min_y, max_y)

func _update_depth_sorting() -> void:
	if shower_wall_sprite == null or shower_wall_sprite.texture == null:
		return

	var wall_top_y := shower_wall_sprite.global_position.y - (shower_wall_sprite.texture.get_height() * shower_wall_sprite.scale.y * 0.5)
	var cutoff_y := wall_top_y + SHOWER_WALL_CUTOFF_LOCAL_Y
	var frame_size := Vector2(sprite.texture.get_width() / sprite.hframes, sprite.texture.get_height())
	var player_top_y := sprite.global_position.y - (frame_size.y * sprite.scale.y * 0.5)

	if player_top_y < cutoff_y:
		sprite.z_index = PLAYER_BEHIND_Z
		shower_wall_sprite.z_index = WALL_FRONT_Z
	else:
		sprite.z_index = PLAYER_FRONT_Z
		shower_wall_sprite.z_index = WALL_BACK_Z

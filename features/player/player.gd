extends CharacterBody2D

const SHOT_SCENE := preload("res://features/player/projectiles/shot.tscn")

@onready var sprite: Sprite2D = $Sprite2D
@onready var firing_sound: AudioStreamPlayer = $FiringSound
@onready var shower_wall_sprite: Sprite2D = get_node_or_null("../ShowerWall/Sprite2D")
const PlayerConstants = preload("res://features/player/player_constants.gd")

var frame_timer := 0.0
var shot_cooldown := 0.0
var facing_left := false
var moving := false
var was_moving := false
var shoot_animation_timer := 0.0

func _ready() -> void:
	sprite.texture = PlayerConstants.STAND_RT_TEXTURE
	sprite.hframes = PlayerConstants.STAND_FRAMES
	sprite.frame = 0
	_update_sprite_scale()
	_clamp_to_level_bounds()
	_update_depth_sorting()
	get_viewport().size_changed.connect(_update_sprite_scale)

func _physics_process(delta: float) -> void:
	shot_cooldown = maxf(0.0, shot_cooldown - delta)
	shoot_animation_timer = maxf(0.0, shoot_animation_timer - delta)
	if Input.is_physical_key_pressed(KEY_SPACE) and shot_cooldown <= 0.0:
		_shoot()

	var input_dir := _get_movement_input()
	var is_shooting := shoot_animation_timer > 0.0
	was_moving = moving
	moving = input_dir != Vector2.ZERO and not is_shooting

	if was_moving and not moving:
		sprite.frame = 0
		frame_timer = 0.0

	if moving:
		velocity = input_dir * PlayerConstants.WALK_SPEED

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
		if shoot_animation_timer > 0.0:
			sprite.frame = (sprite.frame + 1) % PlayerConstants.SHOOT_FRAMES
		elif moving:
			sprite.frame = (sprite.frame + 1) % PlayerConstants.WALK_FRAMES
		else:
			sprite.frame = (sprite.frame + 1) % PlayerConstants.STAND_FRAMES

func _shoot() -> void:
	if shoot_animation_timer <= 0.0:
		sprite.frame = 0
		frame_timer = 0.0
	shoot_animation_timer = PlayerConstants.SHOOT_ANIMATION_DURATION

	var shot_direction := -1 if facing_left else 1
	var shot = SHOT_SCENE.instantiate()
	get_tree().current_scene.add_child(shot)
	var sprite_top := sprite.global_position.y - PlayerConstants.SHOOT_RT_TEXTURE.get_height() * sprite.global_scale.y * 0.5
	shot.global_position = Vector2(global_position.x + shot_direction * 24.0, sprite_top + 20.0 * sprite.global_scale.y)
	shot.call("set_direction", shot_direction)
	firing_sound.play()
	shot_cooldown = PlayerConstants.SHOOT_ANIMATION_DURATION + PlayerConstants.SHOOT_PAUSE

func _get_current_frame_duration() -> float:
	if shoot_animation_timer > 0.0:
		return 1.0 / PlayerConstants.SHOOT_FPS

	if moving:
		return 1.0 / PlayerConstants.WALK_FPS

	if sprite.frame == 0:
		return PlayerConstants.FIRST_FRAME_HOLD

	return 1.0 / PlayerConstants.STAND_FPS

func _set_sprite_state(is_walking: bool, is_facing_left: bool) -> void:
	if shoot_animation_timer > 0.0:
		sprite.texture = PlayerConstants.SHOOT_LT_TEXTURE if is_facing_left else PlayerConstants.SHOOT_RT_TEXTURE
		sprite.hframes = PlayerConstants.SHOOT_FRAMES
		if sprite.frame >= PlayerConstants.SHOOT_FRAMES:
			sprite.frame = 0
	elif is_walking:
		sprite.texture = PlayerConstants.WALK_LT_TEXTURE if is_facing_left else PlayerConstants.WALK_RT_TEXTURE
		sprite.hframes = PlayerConstants.WALK_FRAMES
		if sprite.frame >= PlayerConstants.WALK_FRAMES:
			sprite.frame = 0
	else:
		sprite.texture = PlayerConstants.STAND_LT_TEXTURE if is_facing_left else PlayerConstants.STAND_RT_TEXTURE
		sprite.hframes = PlayerConstants.STAND_FRAMES
		if sprite.frame >= PlayerConstants.STAND_FRAMES:
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
	if InputMap.has_action("move_right") and InputMap.has_action("move_left"):
		x += Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if InputMap.has_action("move_down") and InputMap.has_action("move_up"):
		y += Input.get_action_strength("move_down") - Input.get_action_strength("move_up")

	if x == 0.0 and y == 0.0:
		return Vector2.ZERO

	return Vector2(x, y).normalized()

func _update_sprite_scale() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor: float = minf(viewport_size.x / PlayerConstants.REFERENCE_VIEWPORT.x, viewport_size.y / PlayerConstants.REFERENCE_VIEWPORT.y)
	var integer_factor: float = maxf(1.0, floorf(scale_factor))
	var final_scale: float = PlayerConstants.BASE_SPRITE_SCALE * integer_factor
	sprite.scale = Vector2(final_scale, final_scale)
	_clamp_to_level_bounds()

func _clamp_to_level_bounds() -> void:
	var frame_size := Vector2(sprite.texture.get_width() / sprite.hframes, sprite.texture.get_height())
	var half_size := frame_size * sprite.scale * 0.5
	var min_x := half_size.x
	var max_x := PlayerConstants.LEVEL_SIZE.x - half_size.x
	var min_y := PlayerConstants.TOP_PLAY_AREA_INSET + half_size.y
	var max_y := PlayerConstants.LEVEL_SIZE.y - half_size.y

	position.x = clampf(position.x, min_x, max_x)
	position.y = clampf(position.y, min_y, max_y)

func _update_depth_sorting() -> void:
	sprite.z_index = roundi(global_position.y)
	if shower_wall_sprite == null or shower_wall_sprite.texture == null:
		return

	var wall_top_y := shower_wall_sprite.global_position.y - (shower_wall_sprite.texture.get_height() * shower_wall_sprite.scale.y * 0.5)
	var cutoff_y := wall_top_y + PlayerConstants.SHOWER_WALL_CUTOFF_LOCAL_Y
	var frame_size := Vector2(sprite.texture.get_width() / sprite.hframes, sprite.texture.get_height())
	shower_wall_sprite.z_index = roundi(cutoff_y + frame_size.y * sprite.scale.y * 0.5)

extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

const STAND_FRAMES := 6
const STAND_FPS := 8.0
const FIRST_FRAME_HOLD := 1.0
const REFERENCE_VIEWPORT := Vector2(480.0, 270.0)
const BASE_SPRITE_SCALE := 1.0

var frame_timer := 0.0

func _ready() -> void:
	sprite.frame = 0
	_update_sprite_scale()
	get_viewport().size_changed.connect(_update_sprite_scale)

func _process(delta: float) -> void:
	frame_timer += delta

	while frame_timer >= _get_current_frame_duration():
		frame_timer -= _get_current_frame_duration()
		sprite.frame = (sprite.frame + 1) % STAND_FRAMES

func _get_current_frame_duration() -> float:
	if sprite.frame == 0:
		return FIRST_FRAME_HOLD

	return 1.0 / STAND_FPS

func _update_sprite_scale() -> void:
	var viewport_size := get_viewport_rect().size
	var scale_factor: float = minf(viewport_size.x / REFERENCE_VIEWPORT.x, viewport_size.y / REFERENCE_VIEWPORT.y)
	var integer_factor: float = maxf(1.0, floorf(scale_factor))
	var final_scale: float = BASE_SPRITE_SCALE * integer_factor
	sprite.scale = Vector2(final_scale, final_scale)

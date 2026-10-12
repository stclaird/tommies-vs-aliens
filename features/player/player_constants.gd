extends RefCounted

const STAND_RT_TEXTURE := preload("res://features/player/sprites/tommy-stand-right-Sheet.png")
const STAND_LT_TEXTURE := preload("res://features/player/sprites/tommy-stand-left-Sheet.png")
const WALK_RT_TEXTURE := preload("res://features/player/sprites/tommy-walk-right-Sheet.png")
const WALK_LT_TEXTURE := preload("res://features/player/sprites/tommy-walk-left-Sheet.png")
const SHOOT_RT_TEXTURE := preload("res://features/player/sprites/tommy-shoot-rifle-right.png")
const SHOOT_LT_TEXTURE := preload("res://features/player/sprites/tommy-shoot-rifle-left.png")

const WALK_SPEED := 120.0

const STAND_FRAMES := 6
const STAND_FPS := 8.0
const WALK_FRAMES := 6
const WALK_FPS := 10.0
const SHOOT_FRAMES := 7
const SHOOT_FPS := 14.0
const SHOOT_ANIMATION_DURATION := SHOOT_FRAMES / SHOOT_FPS
const SHOOT_PAUSE := 0.5
const FIRST_FRAME_HOLD := 2.0
const REFERENCE_VIEWPORT := Vector2(480.0, 270.0)
const BASE_SPRITE_SCALE := 1.0
const LEVEL_SIZE := Vector2(1200.0, 600.0)
const TOP_PLAY_AREA_INSET := 48.0
const SHOWER_WALL_CUTOFF_LOCAL_Y := 174.0
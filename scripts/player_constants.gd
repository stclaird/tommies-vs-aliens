extends RefCounted

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
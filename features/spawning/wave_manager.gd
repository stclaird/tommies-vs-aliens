extends Node

signal enemy_defeated(defeated_count: int, total_count: int)
signal all_enemies_defeated

@export var enemy_scenes: Array[PackedScene] = []
@export_range(1, 1000, 1) var total_enemies := 30
@export_range(1, 100, 1) var max_active_enemies := 10
@export var enemy_movement_bounds := Rect2()

var defeated_count := 0
var spawned_count := 0
var active_count := 0

func _ready() -> void:
	if enemy_scenes.is_empty():
		push_error("WaveManager needs at least one enemy scene.")
		return
	_fill_active_slots()

func _fill_active_slots() -> void:
	while active_count < max_active_enemies and spawned_count < total_enemies:
		var enemy = enemy_scenes.pick_random().instantiate()
		if not enemy.has_signal("died") or not enemy.has_method("take_hit"):
			push_error("Wave enemy scenes must provide a died signal and take_hit() method.")
			enemy.free()
			return
		if enemy.has_method("configure_movement_bounds"):
			if enemy_movement_bounds.size.x <= 0.0 or enemy_movement_bounds.size.y <= 0.0:
				push_error("WaveManager requires positive enemy movement bounds for this enemy.")
				enemy.free()
				return
			enemy.call("configure_movement_bounds", enemy_movement_bounds)
		enemy.connect("died", _on_enemy_died)
		get_parent().call_deferred("add_child", enemy)
		active_count += 1
		spawned_count += 1

func _on_enemy_died() -> void:
	active_count -= 1
	defeated_count += 1
	enemy_defeated.emit(defeated_count, total_enemies)

	if defeated_count >= total_enemies:
		all_enemies_defeated.emit()
		return

	_fill_active_slots()
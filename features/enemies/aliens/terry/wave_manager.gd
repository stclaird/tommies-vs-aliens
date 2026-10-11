extends Node

const TERRY_SCENE := preload("res://features/enemies/aliens/terry/terry.tscn")
const TOTAL_TERRIES := 30
const MAX_ACTIVE_TERRIES := 10

@onready var defeated_count_label: Label = get_node("../HUD/TerryCounter/DefeatedCount")
@onready var victory_message: Label = get_node("../HUD/Victory")

var defeated_count := 0
var spawned_count := 0
var active_count := 0

func _ready() -> void:
	_update_defeated_count()
	_fill_active_slots()

func _fill_active_slots() -> void:
	while active_count < MAX_ACTIVE_TERRIES and spawned_count < TOTAL_TERRIES:
		var terry = TERRY_SCENE.instantiate()
		terry.connect("died", _on_terry_died)
		get_parent().call_deferred("add_child", terry)
		active_count += 1
		spawned_count += 1

func _on_terry_died() -> void:
	active_count -= 1
	defeated_count += 1
	_update_defeated_count()

	if defeated_count >= TOTAL_TERRIES:
		victory_message.show()
		get_tree().paused = true
		return

	_fill_active_slots()

func _update_defeated_count() -> void:
	defeated_count_label.text = str(defeated_count)
extends Node2D

@onready var wave_manager: Node = $WaveManager
@onready var defeated_count_label: Label = $HUD/EnemyCounter/DefeatedCount
@onready var victory_message: Label = $HUD/Victory

func _ready() -> void:
	wave_manager.enemy_defeated.connect(_on_enemy_defeated)
	wave_manager.all_enemies_defeated.connect(_on_all_enemies_defeated)
	defeated_count_label.text = "0"

func _on_enemy_defeated(defeated_count: int, total_count: int) -> void:
	defeated_count_label.text = str(defeated_count, "/", total_count)

func _on_all_enemies_defeated() -> void:
	victory_message.show()
	get_tree().paused = true
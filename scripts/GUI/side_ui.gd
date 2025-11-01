extends Node

@export var level_num : Label


func _on_dungeon_level_changed(new_level: int) -> void:
    # format "Basement: %d"
    level_num.text = "Basement: %d" % new_level

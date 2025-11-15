extends Node

@export var level_num : Label
@export var hp_bar : ColorRect
@export var hp_label : Label

var hp_bar_max_width : int

func _ready() -> void:
   hp_bar_max_width = hp_bar.size.x

func initialize(player : Entity) -> void:
    var fighter_component: FighterComponent = player.fighter_component
    if fighter_component:
        fighter_component.hp_changed.connect(_on_hp_changed)
        _on_hp_changed(fighter_component.hp, fighter_component.max_hp)

func _on_dungeon_level_changed(new_level: int) -> void:
    # format "Basement: %d"
    level_num.text = "Basement: %d" % new_level

func _on_hp_changed(hp: int, max_hp: int) -> void:
    var health_ratio: float = float(hp) / float(max_hp)
    hp_bar.size.x = int(health_ratio * float(hp_bar_max_width))
    hp_label.text = "%d / %d" % [hp, max_hp]

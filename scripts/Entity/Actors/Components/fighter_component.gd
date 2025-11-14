class_name FighterComponent
extends Component

signal hp_changed(hp: int, max_hp: int)

var max_hp: int
var hp: int:
    set(value):
        hp = clamp(value, 0, max_hp)
        hp_changed.emit(hp, max_hp)
var base_defense: int
var base_power: int
var defense: int:
    get:
        return base_defense + get_defence_bonus()
var power: int:
    get:
        return base_power + get_power_bonus()

func _init(_definition: FighterComponentDefinition) -> void:
    self.max_hp = _definition.max_hp
    self.hp = _definition.max_hp
    self.base_defense = _definition.base_defense
    self.base_power = _definition.base_power

func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        hp = 0
        print("Player died") # For now, just print a message

func get_defence_bonus() -> int:
    return 0

func get_power_bonus() -> int:
    return 0

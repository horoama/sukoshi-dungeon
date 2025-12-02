class_name OpenInventoryAction
extends Action

func _init() -> void:
    pass

func perform(dungeon: Dungeon, entity: Entity) -> bool:
    SignalBus.open_inventory.emit()
    return true

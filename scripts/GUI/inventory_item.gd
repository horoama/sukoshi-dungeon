class_name InventoryItem
extends Label

var entity: Entity

func _init(item_entity: Entity) -> void:
    self.entity = item_entity
    text = item_entity.name
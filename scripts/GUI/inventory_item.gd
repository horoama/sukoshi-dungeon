class_name InventoryItem
extends Control

@onready var item_name_label : Label = $ItemName
@onready var item_icon_texture_rect : TextureRect = $ItemIcon

var item_entity : Entity

func setup(entity: Entity) -> void:
    self.item_entity = entity
    item_name_label.text = entity.name
    item_icon_texture_rect.texture = entity.texture

func _on_item_used() -> void:
    SignalBus.item_used.emit(item_entity)
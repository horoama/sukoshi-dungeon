class_name InventoryItem
extends Control

@onready var item_name_label : Label = $ItemName
@onready var item_icon_texture_rect : TextureRect = $ItemIcon

func setup(item_entity: Entity) -> void:
    item_name_label.text = item_entity.name
    item_icon_texture_rect.texture = item_entity.texture
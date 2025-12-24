class_name Inventory
extends Control

@onready var item_list_container : BoxContainer = $InventoryListScrollContainer/ItemListContainer
@onready var items : Array[Entity] = []

@export var item_scene : PackedScene

func _ready() -> void:
    SignalBus.update_player_inventory.connect(_on_update_player_inventory)

func _on_update_player_inventory(item_list: Array[Entity]) -> void:
    items = item_list
    _refresh_inventory_display()

func _refresh_inventory_display() -> void:
    for child in item_list_container.get_children():
        item_list_container.remove_child(child)
        child.queue_free()
    for item in items:
        var item_entry = item_scene.instantiate()
        item_entry.get_node("ItemName").text = item.name
        item_entry.get_node("ItemIcon").texture = item.texture
        item_list_container.add_child(item_entry)

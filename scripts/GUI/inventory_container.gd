class_name InventoryContainer
extends ScrollContainer

@onready var inventory : VBoxContainer = $Inventory
@export var item_scene : PackedScene

func _ready() -> void:
    # init signal connection
    SignalBus.update_player_inventory.connect(_on_update_player_inventory)

func _on_update_player_inventory(item_list: Array[Entity]) -> void:
    # remove all existing children
    for n in inventory.get_children():
        inventory.remove_child(n)
        n.queue_free()
    for item in item_list:
        var inventory_item = item_scene.instantiate()
        inventory.add_child(inventory_item)
        inventory_item.setup(item)

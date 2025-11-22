class_name PickupItemAction
extends Action

var entity_to_pickup: Entity

func _init(entity: Entity) -> void:
    super._init(entity)
    entity_to_pickup = entity

func perform(dungeon: Dungeon, entity: Entity) -> bool:
    var inventory_component: InventoryComponent = entity.inventory_component
    if not inventory_component:
        Loggie.error("Entity %s has no InventoryComponent, cannot pick up items." % entity.name)
        return false
    
    if not inventory_component.can_add_item(entity_to_pickup):
        MessageContainer.send_message("Cannot pick up item: Inventory full.") # TODO: Use Enum message
        return false
    
    var map_data: MapData = self.get_map_data()
    map_data.remove_entity(entity_to_pickup.grid_position, entity_to_pickup)
    # delete from scene tree
    ## TODO: use signals to notify other systems of item pickup
    entity_to_pickup.get_parent().remove_child(entity_to_pickup)
    inventory_component.add_item(entity_to_pickup)
    # playerならsignalでGUI更新
    if entity.name == "Player":
        SignalBus.update_player_inventory.emit(inventory_component.items)
    MessageContainer.send_message("Picked up %s." % entity_to_pickup.name) # TODO: Use Enum message
    return true
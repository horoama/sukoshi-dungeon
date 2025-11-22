class_name InteractAction
extends Action

func _init() -> void:
    pass

func perform(dungeon: Dungeon, entity: Entity) -> bool:
    var map_data: MapData = dungeon.current_dungeon_map
    var pos: Vector2i = entity.grid_position
    var tile: Tile = map_data.get_tile(pos)

    # 1) If standing on stairs, use them
    if tile:
        if tile.object_type == Enum.ObjectType.DOWN_STAIRS:
            var down = StairAction.new(Enum.StairDirection.DOWN)
            return down.perform(dungeon, entity)
        elif tile.object_type == Enum.ObjectType.UP_STAIRS:
            var up = StairAction.new(Enum.StairDirection.UP)
            return up.perform(dungeon, entity)

    # 2) If there are items on the same tile, pick up the first one
    var tile_items: Array = map_data.items.get(pos, [])
    if tile_items.size() > 0:
        var item_entity: Entity = tile_items[0]
        var pickup = PickupItemAction.new(item_entity)
        return pickup.perform(dungeon, entity)

    # 3) Look for adjacent actors to interact with (talk/bump)
    var adj_dirs = [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
    for d in adj_dirs:
        var p = pos + d
        var a = map_data.actors.get(p, null)
        if a and a != entity:
            MessageContainer.send_message("You interact with %s." % a.name)
            return true

    # 4) Nothing to do
    MessageContainer.send_message("There is nothing to interact with.")
    return false

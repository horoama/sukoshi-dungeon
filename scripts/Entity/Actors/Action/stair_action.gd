class_name StairAction
extends Action

var direction: String

func _init(direction: String) -> void:
    self.direction = direction


func perform(dungeon: Dungeon, entity: Entity) -> void:
    print("use stair ", direction)
    # check stair is exist
    var map_data: MapData = dungeon.current_dungeon_map
    var tile: Tile = map_data.get_tile(entity.grid_position)
    if direction == "down":
        if tile.object_type == "DOWN_STAIRS":
            dungeon._next_level()
        else:
            print("There is no stairs down here.")
    elif direction == "up":
        if tile.object_type == "DOWNS_STARS":
            print("not implemented yet.")
        else:
            print("There is no stairs up here.")
class_name MovementAction
extends Action

var offset: Vector2i


func _init(dx: int, dy: int) -> void:
    offset = Vector2i(dx, dy)


func perform(dungeon: Dungeon, entity: Entity) -> bool:
    var destination: Vector2i = entity.grid_position + offset
    var map_data: MapData = dungeon.current_dungeon_map
    var destination_tile: Tile = map_data.get_tile(destination)
    if not destination_tile or not map_data.is_passable(destination):
        MessageContainer.send_message(Enum.message_to_string(Enum.Message.CANNOT_MOVE_THERE))
        return false
    entity.move(offset)
    return true

class_name MovementAction
extends Action

var offset: Vector2i


func _init(dx: int, dy: int) -> void:
	offset = Vector2i(dx, dy)


func perform(dungeon: Dungeon, entity: Entity) -> void:
	var destination: Vector2i = entity.grid_position + offset
	var map_data: MapData = dungeon.current_dungeon_map
	var destination_tile: Tile = map_data.get_tile(destination)
	# tileと同じアドレスにnot passibleなキャラやアイテムがいないか確認
	if not destination_tile or not destination_tile.passable:
		MessageContainer.send_message("Cannot move to %s" % destination, Color.RED)
		return
	entity.move(offset)

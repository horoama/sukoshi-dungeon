class_name MapData

var width: int
var height: int
var tiles: Array[Tile]= []  # 2D Array of Tile objects

signal map_updated

func _init(map_width: int, map_height: int) -> void:
	tiles = []
	self.width = map_width
	self.height = map_height
	fill_map("WALL")
	# signal emit
	map_updated.emit()

func fill_map(tile_code: String) -> void:
	tiles.clear()
	for y in range(height):
		for x in range(width):
			var tile = Tile.new(Vector2i(x, y), tile_code)
			tiles.append(tile)

func get_tile_xy(x: int, y: int) -> Tile:
	var index = grid_to_index(Vector2i(x, y))
	if index >= 0 and index < tiles.size():
		return tiles[index]
	return null

func get_tile(pos: Vector2i) -> Tile:
	return get_tile_xy(pos.x, pos.y)

func filter_tiles(func_ref: Callable) -> Array[Tile]:
	var result: Array[Tile] = []
	for tile in tiles:
		if func_ref.call(tile):
			result.append(tile)
	return result

func set_tile(x: int, y: int, tile: Tile) -> void:
	var index = grid_to_index(Vector2i(x, y))
	if index >= 0 and index < tiles.size():
		tiles[index] = tile
	map_updated.emit()

func change_terrain_tile_type(x: int, y: int, tile_code: String) -> void:
	var tile = get_tile_xy(x, y)
	if tile:
		tile.set_terrain_type(tile_code)

func change_object_tile_type(x: int, y: int, tile_code: String) -> void:
	var tile = get_tile_xy(x, y)
	if tile:
		tile.set_object_type(tile_code)

func grid_to_index(grid_pos: Vector2i) -> int:
	# TODO: Add bounds checking
	return grid_pos.x + grid_pos.y * width

func index_to_grid(index: int) -> Vector2i:
	var x = index % width
	@warning_ignore("integer_division")
	var y = index / width
	return Vector2i(x, y)

func is_passable(x: int, y: int) -> bool:
	var tile = get_tile_xy(x, y)
	if tile:
		return tile.passable
	return false

func is_transparent(x: int, y: int) -> bool:
	var tile = get_tile_xy(x, y)
	if tile:
		return tile.transparent
	return false

func reveal_tile(x: int, y: int) -> void:
	var tile = get_tile_xy(x, y)
	if tile and tile.state == "hidden":
		tile.state = "visible"
		map_updated.emit()

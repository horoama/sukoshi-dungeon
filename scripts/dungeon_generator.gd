extends Node
const ArrayUtils = preload("res://scripts/array_utils.gd")

@export var tile_map: TileMapLayer
@export var map_width: int = 15
@export var map_height: int = 10

# store generated data and tile lists as plain Arrays to avoid nested typed collections
var tile_map_data: Array = []
var wall_tiles: Array = []
var floor_tiles: Array = []
var atlas: Vector2i = Vector2i(0, 0)
var tileset_dict: Dictionary = {
	"FLOOR": Vector2i(0, 0),
	"WALL": Vector2i(0, 1),
}

func _ready() -> void:
	tile_map_data = generate_dungeon(15, 10, 0.3)
	update_tile_map()

func init_grid():
	tile_map_data = ArrayUtils.create_2d_array(map_width, map_height, tileset_dict["FLOOR"])

func update_tile_map() -> void:
	for y in range(tile_map_data.size()):
		for x in range(tile_map_data[y].size()):
			var tile_type = tile_map_data[y][x]
			tile_map.set_cell(Vector2i(x, y), 0, tile_type)

# Generate dungeon map
func generate_dungeon(width: int, height: int, wall_rate: float) -> Array:
	var map_data: Array = []
	for y in range(height):
		map_data.append([])
		for x in range(width):
			if randf() < wall_rate:
				map_data[y].append(tileset_dict["WALL"])
				wall_tiles.append(Vector2i(x, y))
			else:
				map_data[y].append(tileset_dict["FLOOR"])
				floor_tiles.append(Vector2i(x, y))
	return map_data

class_name MapData

var TILE_SIZE = 32
var level: int
var width: int
var height: int
var tiles: Array[Tile]= []  # 2D Array of Tile objects
var entities : Array[Entity] = []

signal map_updated

func _init(map_width: int, map_height: int, map_level: int) -> void:
    tiles = []
    self.width = map_width
    self.height = map_height
    self.level = map_level
    fill_map(Enum.TerrainTileType.WALL)
    # signal emit
    map_updated.emit()

func add_entity(entity: Entity) -> void:
    entities.append(entity)
func remove_entity(entity: Entity) -> void:
    entities.erase(entity)

func fill_map(terrain_tile_type: Enum.TerrainTileType) -> void:
    tiles.clear()
    for y in range(height):
        for x in range(width):
            var tile = Tile.new(Vector2i(x, y), terrain_tile_type)
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

func change_terrain_tile_type(x: int, y: int, tile_code: Enum.TerrainTileType) -> void:
    var tile = get_tile_xy(x, y)
    if tile:
        tile.set_terrain_type(tile_code)

func change_object_tile_type(x: int, y: int, tile_code: Enum.ObjectType) -> void:
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
    if tile and tile.state == Enum.TileStatus.HIDDEN:
        tile.state = Enum.TileStatus.VISIBLE
        map_updated.emit()

func tile_to_local(pos: Vector2i) -> Vector2:
    var local_pos = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
    return local_pos

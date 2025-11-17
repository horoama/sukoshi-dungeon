class_name Tile # Make the Tile class globally accessible

# タイルのプロパティ
var position: Vector2i = Vector2i(0, 0) # グリッド上の位置
var terrain_type := Enum.TerrainTileType.WALL
var object_type := Enum.ObjectType.NONE
var terrain_atlas_coords: Vector2i = Vector2i(0, 1) # デフォルトは壁タイルの座標
var object_atlas_coords: Vector2i = Vector2i(0, 1) # デフォルトは壁タイルの座標
var items: Array = [] # List of items on this tile
var state := Enum.TileStatus.HIDDEN
var passable: bool = false
var transparent: bool = false

var terrain_tile := TileDefine.TerrainTile
var object_tile := TileDefine.ObjectTile

var _entities: Array[Entity] = [] # List of entities on this tile

func _init(grid_position: Vector2i = Vector2i(0, 0), terrain_tile_type: Enum.TerrainTileType = Enum.TerrainTileType.FLOOR) -> void:
    position = grid_position
    set_terrain_type(terrain_tile_type)

func set_terrain_type(tile_type: Enum.TerrainTileType) -> void:
    match tile_type:
        Enum.TerrainTileType.FLOOR:
            terrain_type = Enum.TerrainTileType.FLOOR
            terrain_atlas_coords = terrain_tile.FLOOR.ATLAS_COORDS
            passable = true
            transparent = true
        Enum.TerrainTileType.WALL:
            terrain_type = Enum.TerrainTileType.WALL
            terrain_atlas_coords = terrain_tile.WALL.ATLAS_COORDS
            passable = false
            transparent = false
        _:
            terrain_type = Enum.TerrainTileType.FLOOR
            terrain_atlas_coords = terrain_tile.FLOOR.ATLAS_COORDS
            passable = false
            transparent = false

func set_object_type(tile_type: Enum.ObjectType) -> void:
    match tile_type:
        Enum.ObjectType.DOWN_STAIRS:
            object_type = Enum.ObjectType.DOWN_STAIRS
            object_atlas_coords = object_tile.DOWN_STAIRS.ATLAS_COORDS
            passable = true
            transparent = true
        Enum.ObjectType.UP_STAIRS:
            object_type = Enum.ObjectType.UP_STAIRS
            object_atlas_coords = object_tile.UP_STAIRS.ATLAS_COORDS
            passable = true
            transparent = true
        _:
            object_type = Enum.ObjectType.NONE
            object_atlas_coords = object_tile.NONE.ATLAS_COORDS
            passable = false

func add_entity(entity: Entity) -> void:
    if not _entities.has(entity):
        _entities.append(entity)

func remove_entity(entity: Entity) -> void:
    if _entities.has(entity):
        _entities.erase(entity)

func get_entities() -> Array[Entity]:
    return _entities
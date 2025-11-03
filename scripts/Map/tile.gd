class_name Tile  # Make the Tile class globally accessible

# タイルのプロパティ
var position: Vector2i = Vector2i(0, 0) # グリッド上の位置
var terrain_type: String = "WALL"  # e.g., "WALL", "FLOOR"
var object_type: String = "NONE"
var terrain_atlas_coords: Vector2i = Vector2i(0, 1)  # デフォルトは壁タイルの座標
var object_atlas_coords: Vector2i = Vector2i(0, 1)  # デフォルトは壁タイルの座標
var items: Array = []  # List of items on this tile
var state: String = "hidden"  # e.g., "hidden", "visible", "explored"
var passable: bool = false
var transparent: bool = false

var terrain_tile := TileDefine.TerrainTile
var object_tile := TileDefine.ObjectTile

func _init(grid_position: Vector2i = Vector2i(0, 0), tile_code: String = "FLOOR") -> void:
    position = grid_position
    set_terrain_type(tile_code)

func set_terrain_type(tile_type: String) -> void:
    match tile_type:
        "FLOOR":
            terrain_type = "FLOOR"
            terrain_atlas_coords = terrain_tile.FLOOR.ATLAS_COORDS
            passable = true
            transparent = true
        "WALL":
            terrain_type = "WALL"
            terrain_atlas_coords = terrain_tile.WALL.ATLAS_COORDS
            passable = false
            transparent = false
        "DOWN_STAIRS":
            terrain_type = "DOWN_STAIRS"
            terrain_atlas_coords = terrain_tile.DOWN_STAIRS.ATLAS_COORDS
            passable = true
            transparent = true
        _:
            terrain_type = "UNKNOWN"
            terrain_atlas_coords = terrain_tile.FLOOR.ATLAS_COORDS
            passable = false
            transparent = false

func set_object_type(tile_code: String) -> void:
    match tile_code:
        "DOWN_STAIRS":
            object_type = "DOWN_STAIRS"
            object_atlas_coords = object_tile.DOWN_STAIRS.ATLAS_COORDS
            passable = true
            transparent = true
        "UP_STAIRS":
            object_type = "UP_STAIRS"
            object_atlas_coords = object_tile.UP_STAIRS.ATLAS_COORDS
            passable = true
            transparent = true
        _:
            object_type = "UNKNOWN"
            object_atlas_coords = object_tile.NONE.ATLAS_COORDS
            passable = false
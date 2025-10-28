class_name Tile  # Make the Tile class globally accessible

const TILE_SIZE := Vector2i(32, 32)  # タイルのサイズ（ピクセル単位）


# TODO: タイル用の辞書作成
const FLOOR := Vector2i(0, 0)
const WALL := Vector2i(0, 1)
const DOWN_STAIRS := Vector2i(7, 16)

var position: Vector2i = Vector2i(0, 0)
var type: String = "wall"  # e.g., "wall", "floor"
var atlas_coords: Vector2i = Vector2i(0, 1)  # デフォルトは壁タイルの座標
var object_atlas_coords: Vector2i = Vector2i(0, 1)  # デフォルトは壁タイルの座標
var items: Array = []  # List of items on this tile
var state: String = "hidden"  # e.g., "hidden", "visible", "explored"
var passable: bool = false
var transparent: bool = false

func _init(grid_position: Vector2i = Vector2i(0, 0), tile_type: Vector2i = WALL) -> void:
    position = TILE_SIZE * grid_position
    set_type(tile_type)

func set_type(tile_type: Vector2i) -> void:
    match tile_type:
        FLOOR:
            type = "floor"
            atlas_coords = tile_type
            passable = true
            transparent = true
        WALL:
            type = "wall"
            atlas_coords = tile_type
            passable = false
            transparent = false
        DOWN_STAIRS:
            type = "down_stairs"
            atlas_coords = tile_type
            passable = true
            transparent = true
        _:
            type = "unknown"
            atlas_coords = FLOOR
            passable = false
            transparent = false

func set_object_type(tile_type: Vector2i) -> void:
    match tile_type:
        DOWN_STAIRS:
            type = "down_stairs"
            object_atlas_coords = tile_type
            passable = true
            transparent = true
        _:
            type = "unknown"
            atlas_coords = FLOOR
            passable = false
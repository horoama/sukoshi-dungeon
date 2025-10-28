extends Node

# 現在のレベルのダンジョンデータ
var current_dungeon_map: MapData
# タイルマップレイヤーへの参照
@export var terrain_tile_map: TileMapLayer
@export var object_tile_map: TileMapLayer
# dungeon_generatorノードへの参照
@onready var dungeon_generator = $DungeonGenerator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    current_dungeon_map = dungeon_generator.generate_cave(
        dungeon_generator.map_width,
        dungeon_generator.map_height,
        dungeon_generator.WALL_RATE,
        dungeon_generator.SIMULATION_STEPS,
        dungeon_generator.ROOM_ATTEMPTS,
        dungeon_generator.ROOM_MIN_SIZE,
        dungeon_generator.ROOM_MAX_SIZE
    )
    dungeon_generator.finalize_map(current_dungeon_map)
    # タイルマップを更新
    update_tile_map(current_dungeon_map)

# tile_map_dataに基づいてタイルマップを更新する関数
func update_tile_map(map_data: MapData) -> void:
    for i in map_data.tiles.size():
        var grid_pos = map_data.index_to_grid(i)
        terrain_tile_map.set_cell(grid_pos, 0, map_data.get_tile(grid_pos).atlas_coords) 
        # オブジェクトタイルの更新
        if map_data.get_tile(grid_pos).object_atlas_coords == Tile.DOWN_STAIRS:
            object_tile_map.set_cell(grid_pos, 1, map_data.get_tile(grid_pos).object_atlas_coords)

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

func _next_level() -> void:
    var next_dungeon_map: MapData = dungeon_generator.generate_cave(
        dungeon_generator.map_width,
        dungeon_generator.map_height,
        dungeon_generator.WALL_RATE,
        dungeon_generator.SIMULATION_STEPS,
        dungeon_generator.ROOM_ATTEMPTS,
        dungeon_generator.ROOM_MIN_SIZE,
        dungeon_generator.ROOM_MAX_SIZE
    )
    # 上り階段を設置
    var prev_stairs : Array[Tile] = current_dungeon_map.filter_tiles(func(t: Tile) -> bool:
        return t.type == "DOWN_STAIRS"
    )
    dungeon_generator.set_previous_stairs(next_dungeon_map, prev_stairs)
    # 下り階段を設置
    dungeon_generator.finalize_map(next_dungeon_map)
    # タイルマップを更新
    update_tile_map(next_dungeon_map)
    current_dungeon_map = next_dungeon_map

# tile_map_dataに基づいてタイルマップを更新する関数
func update_tile_map(map_data: MapData) -> void:
    # clear existing tiles
    terrain_tile_map.clear()
    object_tile_map.clear()
    # set new tiles
    for i in map_data.tiles.size():
        var grid_pos = map_data.index_to_grid(i)
        terrain_tile_map.set_cell(grid_pos, 0, map_data.get_tile(grid_pos).terrain_atlas_coords) 
        # オブジェクトタイルの更新
        if map_data.get_tile(grid_pos).type == "DOWN_STAIRS" or map_data.get_tile(grid_pos).type == "UP_STAIRS":
            object_tile_map.set_cell(grid_pos, 1, map_data.get_tile(grid_pos).object_atlas_coords)

extends Node

@export var dungeon_config: DungeonConfig
# 現在のレベルのダンジョンデータ
var current_dungeon_map: MapData
# タイルマップレイヤーへの参照
@export var terrain_tile_map: TileMapLayer
@export var object_tile_map: TileMapLayer
# dungeon_generatorノードへの参照
@onready var dungeon_generator = $DungeonGenerator

@export var player_scene : PackedScene

var player: Node

# 階層が変わったシグナル
signal level_changed(new_level: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    current_dungeon_map = dungeon_generator.generate_cave(dungeon_config, null)
    dungeon_generator.finalize_map(current_dungeon_map)
    # タイルマップを更新
    update_tile_map(current_dungeon_map)
    spawn_player(Vector2i(1, 1))


func _next_level() -> void:
    var next_dungeon_map: MapData = dungeon_generator.generate_cave(dungeon_config, current_dungeon_map)
    # 下り階段を設置
    dungeon_generator.finalize_map(next_dungeon_map)
    # タイルマップを更新
    update_tile_map(next_dungeon_map)
    current_dungeon_map = next_dungeon_map
    # emit signal
    level_changed.emit(current_dungeon_map.level)
    player.move_to_xy(1, 1)

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
        if map_data.get_tile(grid_pos).object_type != "NONE":
            object_tile_map.set_cell(grid_pos, 1, map_data.get_tile(grid_pos).object_atlas_coords)

func spawn_player(pos: Vector2i) -> void:
    player = player_scene.instantiate()
    add_child(player)
    player.player_moved.connect(move_player)

func move_player(pos: Vector2i) -> void:
    print("charactor move to", pos)

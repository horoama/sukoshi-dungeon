extends Node

@export var dungeon_config: DungeonConfig
# 現在のレベルのダンジョンデータ
var current_dungeon_map: MapData
# タイルマップレイヤーへの参照
@export var terrain_tile_map: TileMapLayer
@export var object_tile_map: TileMapLayer
@export var dungeon_map_loot: Node

# dungeon_generatorノードへの参照
@onready var dungeon_generator = $DungeonGenerator

@export var player_scene : PackedScene

var TILE_SIZE = 32

var player: Node

# 階層が変わったシグナル
signal level_changed(new_level: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    current_dungeon_map = dungeon_generator.generate_cave(dungeon_config, null)
    dungeon_generator.finalize_map(current_dungeon_map)
    # タイルマップを更新
    update_tile_map(current_dungeon_map)
    spawn_player()


func _next_level() -> void:
    var next_dungeon_map: MapData = dungeon_generator.generate_cave(dungeon_config, current_dungeon_map)
    # 下り階段を設置
    dungeon_generator.finalize_map(next_dungeon_map)
    # タイルマップを更新
    update_tile_map(next_dungeon_map)
    current_dungeon_map = next_dungeon_map
    # emit signal
    level_changed.emit(current_dungeon_map.level)

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

func spawn_player() -> void:
    var emptys = current_dungeon_map.filter_tiles(func(tile: Tile) -> bool:
        return tile.terrain_type == "FLOOR" and tile.object_type == "NONE"
    )
    # choose random floor
    emptys.shuffle()
    var selected = emptys[0]
    print("selected: ", selected.position)
    player = player_scene.instantiate()
    add_child(player)
    #player.move_to(selected.position)
    player.move_to(selected.position)
    player.player_moved.connect(_on_player_moved)

func _on_player_moved(pos: Vector2i) -> void:
    print("moved: ", pos)
        

func tile_to_local(pos: Vector2i) -> Vector2:
    var local_pos = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
    return local_pos

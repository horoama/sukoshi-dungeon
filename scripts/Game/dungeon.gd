class_name Dungeon
extends Node

@export var dungeon_config: DungeonConfig
# 現在のレベルのダンジョンデータ
var current_dungeon_map: MapData
# タイルマップレイヤーへの参照
@export var terrain_tile_map: TileMapLayer
@export var object_tile_map: TileMapLayer

# dungeon_generatorノードへの参照
@onready var dungeon_generator = $DungeonGenerator

const player_definition: EntityDefinition = preload("res://assets/definition/entity/actor/entity_definition_player.tres")

@onready var player: Entity
@onready var event_handler: EventHandler = $EventHandler
@onready var entities: Node = $Entities
@onready var side_ui: Node = $SideUI


var TILE_SIZE = 32

# 階層が変わったシグナル
signal level_changed(new_level: int)

func _physics_process(_delta: float) -> void:
    var action: Action = event_handler.get_action()
    if action:
        action.perform(self, player)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    current_dungeon_map = dungeon_generator.generate_cave(dungeon_config, null)
    dungeon_generator.finalize_map(current_dungeon_map)
    # タイルマップを更新
    update_tile_map(current_dungeon_map)
    spawn_player()


func next_level() -> void:
    entities.remove_child(player)
    var next_dungeon_map: MapData = dungeon_generator.generate_cave(dungeon_config, current_dungeon_map)
    # 下り階段を設置
    dungeon_generator.finalize_map(next_dungeon_map)
    # タイルマップを更新
    update_tile_map(next_dungeon_map)
    current_dungeon_map = next_dungeon_map
    entities.add_child(player)
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
        if map_data.get_tile(grid_pos).object_type != Enum.ObjectType.NONE:
            object_tile_map.set_cell(grid_pos, 1, map_data.get_tile(grid_pos).object_atlas_coords)

func spawn_player() -> void:
    var emptys = current_dungeon_map.filter_tiles(func(tile: Tile) -> bool:
        # フロアタイルかつオブジェクト無しのタイルを抽出
        return tile.terrain_type == Enum.TerrainTileType.FLOOR and tile.object_type == Enum.ObjectType.NONE
    )
    # choose random floor
    emptys.shuffle()
    var selected = emptys[0]
    player = Entity.new(current_dungeon_map, selected.position, player_definition)
    entities.add_child(player)
    side_ui.initialize(player)

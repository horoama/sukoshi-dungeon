class_name Dungeon
extends Node
# ゲームのメインループとダンジョン管理を行うコアクラス
#
# ダンジョン生成、プレイヤーのスポーン、エンティティ管理、階層移動などの
# ゲーム全体の主要なフローを制御します。
# 入力処理の結果に基づいてアクションを実行し、ゲーム状態を更新します。

@export var dungeon_config: DungeonConfig
# 現在のレベルのダンジョンデータ
var current_dungeon_map: MapData
# ターン管理
var turn_manager: TurnManager
# タイルマップレイヤーへの参照（地形用とオブジェクト用）
@export var terrain_tile_map: TileMapLayer
@export var object_tile_map: TileMapLayer

# ダンジョン生成ロジックを持つノードへの参照
@onready var dungeon_generator = $DungeonGenerator

# プレイヤー定義のプリロード
const player_definition: EntityDefinition = preload("res://assets/definition/entity/actor/entity_definition_player.tres")

# ゲーム内の主要な参照
@onready var player: Entity
@onready var event_handler: EventHandler = $EventHandler
@onready var entities: Node = $DungeonTileMap/Entities
@onready var side_ui: Node = $SideUI
@onready var _game_menu_scene: PackedScene = preload("res://scenes/game_menu_ui.tscn")
@onready var game_menu: Node = null


var TILE_SIZE = 32

# 階層が変わったときに発行されるシグナル
signal level_changed(new_level: int)

# 物理プロセス（ゲームループ）
#
# 毎フレームプレイヤーの入力を監視し、アクションがあれば実行します。
#
# @param _delta: 前回のフレームからの経過時間（ここでは未使用）
func _physics_process(_delta: float) -> void:
    var action: Action = event_handler.get_action()
    if action and player:
        var result = action.perform(self, player)
        # アクションが成功した場合、プレイヤーのターンを終了して敵のターンへ移行
        if result:
            turn_manager.change_state(TurnManager.TurnState.ENEMY_TURN)

# 初期化処理
#
# 初回のダンジョン生成、マップ表示更新、プレイヤーの配置、UIの初期化を行います。
func _ready() -> void:
    # ターンマネージャーの初期化と設定
    turn_manager = TurnManager.new()
    add_child(turn_manager)
    event_handler.turn_manager = turn_manager

    # ターン状態変更時のシグナル接続
    turn_manager.turn_started.connect(_on_turn_started)

    current_dungeon_map = dungeon_generator.generate_cave(dungeon_config, null)
    dungeon_generator.finalize_map(current_dungeon_map)
    # タイルマップを更新
    update_tile_map(current_dungeon_map)
    spawn_player()
    # ゲームメニューUIをインスタンス化（デフォルトは非表示）
    var gm = _game_menu_scene.instantiate()
    add_child(gm)
    game_menu = gm

# 次の階層へ移動する処理
#
# 現在のマップのエンティティをクリアし、新しい階層のダンジョンを生成します。
# プレイヤーを新しいマップに再配置し、タイルマップを更新します。
func next_level() -> void:
    # 現在のマップからエンティティを削除し表示させないようにする
    for entity in entities.get_children():
        remove_entity_from_map(current_dungeon_map, entity.grid_position, entity)

    # 新しいマップを生成（前のマップの情報を一部引き継ぐ）
    var next_dungeon_map: MapData = dungeon_generator.generate_cave(dungeon_config, current_dungeon_map)
    dungeon_generator.finalize_map(next_dungeon_map)

    # タイルマップとデータを更新
    update_tile_map(next_dungeon_map)
    current_dungeon_map = next_dungeon_map
    player.map_data = current_dungeon_map

    # プレイヤーを再配置
    add_entity_to_map(current_dungeon_map, player.grid_position, player)

    # シグナル発行
    level_changed.emit(current_dungeon_map.level)

# マップデータに基づいてTileMapLayer（画面表示）を更新する関数
#
# 論理的なMapDataの内容を、GodotのTileMapLayerのセル情報に反映させます。
#
# @param map_data: 表示するマップデータ
func update_tile_map(map_data: MapData) -> void:
    # 既存のタイルをクリア
    terrain_tile_map.clear()
    object_tile_map.clear()

    # 全タイルの情報をTileMapLayerにセット
    for i in map_data.tiles.size():
        var grid_pos = map_data.index_to_grid(i)
        # 地形レイヤーの更新
        terrain_tile_map.set_cell(grid_pos, 0, map_data.get_tile(grid_pos).terrain_atlas_coords) 
        # オブジェクトレイヤーの更新（階段など）
        if map_data.get_tile(grid_pos).object_type != Enum.ObjectType.NONE:
            object_tile_map.set_cell(grid_pos, 1, map_data.get_tile(grid_pos).object_atlas_coords)

# プレイヤーをスポーンさせる関数
#
# ランダムな床タイルを選んでプレイヤーを配置します。
# 初回ゲーム開始時に呼ばれます。
func spawn_player() -> void:
    var emptys = current_dungeon_map.filter_tiles(func(tile: Tile) -> bool:
        # フロアタイルかつオブジェクト無しのタイルを抽出
        return tile.terrain_type == Enum.TerrainTileType.FLOOR and tile.object_type == Enum.ObjectType.NONE
    )
    # ランダムな場所を選択
    emptys.shuffle()
    var selected = emptys[0]

    # プレイヤーエンティティを生成して配置
    player = Entity.new(current_dungeon_map, selected.position, "player")
    add_entity_to_map(current_dungeon_map, selected.position, player)
    side_ui.initialize(player)

# エンティティをマップとシーンツリーから削除する関数
#
# @param map_data: 対象のマップデータ
# @param grid_pos: エンティティの現在位置
# @param entity: 削除するエンティティ
func remove_entity_from_map(map_data: MapData, grid_pos: Vector2i, entity: Entity) -> void:
    map_data.remove_entity(grid_pos, entity)
    entities.remove_child(entity)

# エンティティをマップとシーンツリーに追加する関数
#
# @param map_data: 対象のマップデータ
# @param grid_pos: 配置する位置
# @param entity: 追加するエンティティ
func add_entity_to_map(map_data: MapData, grid_pos: Vector2i, entity: Entity) -> void:
    map_data.add_entity(grid_pos, entity)
    entities.add_child(entity)


# ターン開始時のハンドラ
#
# @param state: 開始したターンの状態
func _on_turn_started(state: TurnManager.TurnState) -> void:
    match state:
        TurnManager.TurnState.PLAYER_TURN:
            pass
            # プレイヤーの入力待ち状態になります（EventHandlerで制御）
        TurnManager.TurnState.ENEMY_TURN:
            # 敵の処理（現在は仮実装）
            # 将来的にはここで敵のAI処理を行う
            _process_enemy_turn()

# 敵のターン処理
#
# 現時点では即座にプレイヤーのターンに戻します。
func _process_enemy_turn() -> void:
    # TODO: 敵の行動処理を実装
    # 敵の行動が終わったらプレイヤーターンに戻す
    turn_manager.change_state(TurnManager.TurnState.PLAYER_TURN)

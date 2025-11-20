class_name StairAction
extends Action

# 階段の方向（enum を利用）
var direction: int

func _init(dir: int) -> void:
    # 引数は Enum.StairDirection の値を想定
    # パラメータ名を変更してクラス変数とのシャドウを避ける
    self.direction = dir


func perform(dungeon: Dungeon, entity: Entity) -> bool:
    # 現在地のタイルを取得
    var map_data: MapData = dungeon.current_dungeon_map
    var tile: Tile = map_data.get_tile(entity.grid_position)
    
    # 方向に応じて階段の処理を実行（match で分岐）
    match direction:
        Enum.StairDirection.DOWN:
            _use_down_stairs(dungeon, tile)
            return true
        Enum.StairDirection.UP:
            _use_up_stairs(dungeon, tile)
            return true
    return false

func _use_down_stairs(dungeon: Dungeon, tile: Tile) -> void:
    # タイル上に DOWN_STAIRS があるかチェック
    if tile.object_type == Enum.ObjectType.DOWN_STAIRS:
        print(Enum.message_to_string(Enum.Message.STAIR_DOWN_MOVE))
        dungeon.next_level()
    else:
        print(Enum.message_to_string(Enum.Message.STAIR_DOWN_NOT_FOUND))


func _use_up_stairs(_dungeon: Dungeon, tile: Tile) -> void:
    # タイル上に UP_STAIRS があるかチェック
    if tile.object_type == Enum.ObjectType.UP_STAIRS:
        print(Enum.message_to_string(Enum.Message.STAIR_UP_MOVE))
        # 上り処理（未実装ならコメントのまま）
        # dungeon.previous_level()
    else:
        print(Enum.message_to_string(Enum.Message.STAIR_UP_NOT_FOUND))

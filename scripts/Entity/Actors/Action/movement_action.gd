class_name MovementAction
extends Action
# エンティティの移動アクション
#
# 指定されたオフセット（dx, dy）だけエンティティを移動させようと試みます。
# 移動先に障害物がある場合は移動せず、失敗として扱われます。

var offset: Vector2i

# 初期化関数
#
# @param dx: X方向の移動量
# @param dy: Y方向の移動量
func _init(dx: int, dy: int) -> void:
    offset = Vector2i(dx, dy)

# 移動を実行するメソッド
#
# 1. 移動先の座標を計算
# 2. 移動先が通行可能かチェック（地形、他エンティティ）
# 3. 通行不可ならメッセージを表示して false を返す
# 4. 通行可能ならエンティティを移動させて true を返す
#
# @param dungeon: ダンジョンへの参照
# @param entity: 移動するエンティティ
# @return: 移動成功なら true
func perform(dungeon: Dungeon, entity: Entity) -> bool:
    var destination: Vector2i = entity.grid_position + offset
    var map_data: MapData = dungeon.current_dungeon_map
    var destination_tile: Tile = map_data.get_tile(destination)

    # 移動不可の判定
    if not destination_tile or not map_data.is_passable(destination):
        MessageContainer.send_message(Enum.message_to_string(Enum.Message.CANNOT_MOVE_THERE))
        return false

    # 移動処理
    entity.move(offset)
    return true

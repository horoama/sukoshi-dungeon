class_name Enum

# プロジェクト内で使う定数・enum を集約するファイル
# ここに追加すれば、文字列による分散管理やタイプミスを防げます。

# 階段の方向
enum StairDirection {
    DOWN,
    UP,
}

# タイルに置かれるオブジェクトの種類（文字列としてタイルに保存される値と対応）
enum ObjectType {
    NONE,
    DOWN_STAIRS,
    UP_STAIRS,
}

enum TileStatus {
    HIDDEN,
    VISIBLE,
    EXPLORED,
}

# 地形の種類（WALL / FLOOR など）
enum TerrainTileType {
    WALL,
    FLOOR,
}

# 表示用メッセージのキー
enum Message {
    STAIR_DOWN_MOVE,
    STAIR_UP_MOVE,
    STAIR_DOWN_NOT_FOUND,
    STAIR_UP_NOT_FOUND,
    CANNOT_MOVE_THERE,
    ATTACK_DESCRIPTION,
    DAMAGE_DEALT,
    NO_DAMAGE,
}


# ===== ヘルパー =====
## default english messages
static func message_to_string(m: int) -> String:
    match m:
        Message.STAIR_DOWN_MOVE:
            return "You descend the stairs."
        Message.STAIR_UP_MOVE:
            return "You ascend the stairs."
        Message.STAIR_DOWN_NOT_FOUND:
            return "There are no stairs leading down here."
        Message.STAIR_UP_NOT_FOUND:
            return "There are no stairs leading up here."
        Message.CANNOT_MOVE_THERE:
            return "You cannot move there."
        Message.ATTACK_DESCRIPTION:
            return "%s attacks %s!"
        Message.DAMAGE_DEALT:
            return "%d damage!"
        Message.NO_DAMAGE:
            return "No damage."
        _:
            return ""

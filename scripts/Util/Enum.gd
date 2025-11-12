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
}


# ===== ヘルパー =====
static func message_to_string(m: int) -> String:
    match m:
        Message.STAIR_DOWN_MOVE:
            return "下の階へ移動します"
        Message.STAIR_UP_MOVE:
            return "上の階へ移動します"
        Message.STAIR_DOWN_NOT_FOUND:
            return "ここには下への階段がありません"
        Message.STAIR_UP_NOT_FOUND:
            return "ここには上への階段がありません"
        _:
            return ""

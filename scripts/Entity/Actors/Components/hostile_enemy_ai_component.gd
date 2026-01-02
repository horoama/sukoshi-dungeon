class_name HostileEnemyAIComponent
extends BaseAIComponent
# 敵対的な敵のAIコンポーネント
#
# 状態を持ち、プレイヤーを発見すると追跡モードに切り替わります。

enum State { WANDERING, HUNTING }

const DIRECTIONS = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

var current_state: State = State.WANDERING

# AIの行動を実行するメソッド
#
# @param dungeon: 現在のダンジョンコンテキスト
# @param entity: このAIを持つエンティティ
func perform(dungeon: Dungeon, entity: Entity) -> void:
    # 視界チェックと状態更新
    if _can_see_player(dungeon, entity):
        current_state = State.HUNTING
    elif current_state == State.HUNTING:
        # プレイヤーを見失った場合（簡易的にWANDERINGに戻す）
        # 将来的には「最後の目撃地点」に行くなどの拡張が可能
        current_state = State.WANDERING

    match current_state:
        State.HUNTING:
            _perform_hunt(dungeon, entity)
        State.WANDERING:
            _perform_wander(dungeon, entity)

# プレイヤーが見えているかチェック
func _can_see_player(dungeon: Dungeon, entity: Entity) -> bool:
    var player = dungeon.player
    if not player:
        return false

    var line_points = GridGeometry.get_line(entity.grid_position, player.grid_position)

    # 始点（自分）と終点（プレイヤー）を除く、途中のタイルが透明かどうかをチェック
    for i in range(1, line_points.size() - 1):
        var point = line_points[i]
        if not dungeon.current_dungeon_map.is_transparent(point):
            return false

    return true

# 追跡行動（攻撃または移動）
func _perform_hunt(dungeon: Dungeon, entity: Entity) -> void:
    var player = dungeon.player
    var map_data = dungeon.current_dungeon_map

    # 1. 隣接攻撃チェック
    # 隣接しているなら確実に攻撃する
    for dir in DIRECTIONS:
        var target_pos = entity.grid_position + dir
        var actor = map_data.actors.get(target_pos)
        if actor and actor == player:
            BumpAction.new(dir.x, dir.y).perform(dungeon, entity)
            return

    # 2. プレイヤーに近づく移動 (Greedy Pathfinding)
    var best_dir = Vector2i.ZERO
    var min_dist = float("inf")
    var valid_move_found = false

    # 候補の中から最もプレイヤーに近い位置を選出
    for dir in DIRECTIONS:
        var next_pos = entity.grid_position + dir

        # 移動先が通行可能であることを確認（簡易チェック）
        # is_passableはアクターがいるとfalseを返すが、プレイヤー以外の敵がいる場合も避けたいのでこれでOK
        if not map_data.is_passable(next_pos):
             continue

        var dist = next_pos.distance_squared_to(player.grid_position)
        if dist < min_dist:
            min_dist = dist
            best_dir = dir
            valid_move_found = true

    if valid_move_found:
        BumpAction.new(best_dir.x, best_dir.y).perform(dungeon, entity)
    else:
        # 近づけない（行き止まりなど）ならランダム移動にフォールバック
        _perform_wander(dungeon, entity)

# 徘徊行動（ランダム移動）
func _perform_wander(dungeon: Dungeon, entity: Entity) -> void:
    var random_dir = DIRECTIONS.pick_random()
    BumpAction.new(random_dir.x, random_dir.y).perform(dungeon, entity)

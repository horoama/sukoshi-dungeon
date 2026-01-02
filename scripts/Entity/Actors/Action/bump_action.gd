class_name BumpAction
extends Action
# 移動または攻撃を決定するアクション
#
# 移動先を確認し、敵がいれば攻撃（MeleeAction）、
# いなければ移動（MovementAction）を行います。

var offset: Vector2i

# 初期化関数
#
# @param dx: X方向の移動量
# @param dy: Y方向の移動量
func _init(dx: int, dy: int) -> void:
    offset = Vector2i(dx, dy)

# アクション実行メソッド
#
# 移動先の状況に応じて、攻撃か移動を委譲します。
#
# @param dungeon: ダンジョンへの参照
# @param entity: 行動するエンティティ
# @return: アクション成功なら true
func perform(dungeon: Dungeon, entity: Entity) -> bool:
    var dest: Vector2i = entity.grid_position + offset
    var map_data: MapData = dungeon.current_dungeon_map

    var target: Entity = map_data.actors.get(dest)

    # ターゲットが存在し、かつ自分自身でない場合（念のため）
    if target and target != entity:
        # ここで敵対関係をチェックすべきだが、簡易的に全ての他Actorを攻撃対象とする
        # 必要であれば entity.ai_type などをチェックする
        # 現状はRoguelikeのBump Attackとして、そこにいるActorを攻撃する
        return MeleeAction.new(target).perform(dungeon, entity)
    else:
        return MovementAction.new(offset.x, offset.y).perform(dungeon, entity)

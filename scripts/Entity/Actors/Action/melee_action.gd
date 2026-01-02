class_name MeleeAction
extends Action
# 近接攻撃のアクション
#
# 隣接する敵に対して攻撃を行います。

var target: Entity

# 初期化関数
#
# @param target: 攻撃対象のエンティティ
func _init(target: Entity) -> void:
    self.target = target

# 攻撃を実行するメソッド
#
# ダメージ計算を行い、対象に適用し、ログを表示します。
#
# @param dungeon: ダンジョンへの参照
# @param entity: 攻撃を行うエンティティ
# @return: 攻撃成功なら true
func perform(dungeon: Dungeon, entity: Entity) -> bool:
    if not target or not target.fighter_component:
        return false

    var damage: int = entity.fighter_component.power - target.fighter_component.defense

    var attack_desc: String = Enum.message_to_string(Enum.Message.ATTACK_DESCRIPTION) % [entity.name, target.name]
    var damage_desc: String

    if damage > 0:
        damage_desc = Enum.message_to_string(Enum.Message.DAMAGE_DEALT) % damage
        target.fighter_component.take_damage(damage)
    else:
        damage_desc = Enum.message_to_string(Enum.Message.NO_DAMAGE)
        target.fighter_component.take_damage(0)

    MessageContainer.send_message(attack_desc + "\n" + damage_desc)
    Loggie.debug("Melee attack: %s -> %s (Damage: %d)" % [entity.name, target.name, damage])

    return true

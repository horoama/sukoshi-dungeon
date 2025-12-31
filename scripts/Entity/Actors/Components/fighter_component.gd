class_name FighterComponent
extends Component
# 戦闘関連のステータスとロジックを管理するコンポーネント
#
# HP（体力）、攻撃力、防御力などの数値を保持し、
# ダメージ計算や回復処理を行います。

signal hp_changed(hp: int, max_hp: int)

# 最大HP
var max_hp: int
# 現在のHP。変更されると hp_changed シグナルを発行します。
var hp: int:
    set(value):
        hp = clamp(value, 0, max_hp)
        hp_changed.emit(hp, max_hp)
# 基礎防御力
var base_defense: int
# 基礎攻撃力
var base_power: int
# 最終的な防御力（基礎値 + ボーナス）
var defense: int:
    get:
        return base_defense + get_defence_bonus()
# 最終的な攻撃力（基礎値 + ボーナス）
var power: int:
    get:
        return base_power + get_power_bonus()

# 初期化関数
#
# 定義リソースから基本ステータスを読み込みます。
#
# @param _definition: FighterComponentの定義データ
func _init(_definition: FighterComponentDefinition) -> void:
    self.max_hp = _definition.max_hp
    self.hp = _definition.max_hp
    self.base_defense = _definition.base_defense
    self.base_power = _definition.base_power

# ダメージを受ける処理
#
# HPを減少させ、0以下になった場合の死亡ログなどを出力します。
#
# @param amount: 受けるダメージ量
func take_damage(amount: int) -> void:
    hp -= amount
    if hp <= 0:
        hp = 0
        Loggie.info("Player died") # 現在はログ出力のみ

# HPを回復する処理
#
# 指定量だけHPを回復させます。最大HPを超えることはありません。
#
# @param amount: 回復量
# @return: 実際に回復した量
func heal(amount: int) -> int:
    var old_hp: int = hp
    hp += amount
    return hp - old_hp

# 防御力ボーナスを取得する（拡張用）
#
# 装備品やバフによる追加防御力を返す想定です。現在は0を返します。
#
# @return: 防御力ボーナス値
func get_defence_bonus() -> int:
    return 0

# 攻撃力ボーナスを取得する（拡張用）
#
# 装備品やバフによる追加攻撃力を返す想定です。現在は0を返します。
#
# @return: 攻撃力ボーナス値
func get_power_bonus() -> int:
    return 0

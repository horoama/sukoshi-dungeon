class_name Action
extends RefCounted
# ゲーム内の「行動」を表す基底クラス (Command Pattern)
#
# エンティティが実行する全てのアクション（移動、攻撃、アイテム使用など）は
# このクラスを継承して実装されます。
#
# このパターンにより、入力処理とゲームロジックを分離し、
# アクションのキューイングやAIによる行動決定を容易にします。

var entity: Entity

# 初期化関数
#
# @param entity: このアクションを実行する主体となるエンティティ
func _init(entity: Entity) -> void:
    self.entity = entity

# アクションを実行するメソッド
#
# サブクラスでオーバーライドして具体的な処理を記述します。
#
# @param dungeon: ゲームの世界（ダンジョン）への参照
# @param entity: アクションを実行するエンティティ（_initで渡されたものと同じ場合が多いが、柔軟性のため引数でも取る）
# @return: アクションが成功した場合は true、失敗した場合（壁にぶつかったなど）は false
func perform(dungeon: Dungeon, entity: Entity) -> bool:
    return false

# 関連するマップデータを取得するヘルパー関数
#
# @return: エンティティが所属するMapData
func get_map_data() -> MapData:
    return self.entity.map_data

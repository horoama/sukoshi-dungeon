class_name BaseAIComponent
extends Node
# AIコンポーネントの基底クラス
#
# エンティティの意思決定ロジックを担当します。
# 継承先のクラスで perform メソッドをオーバーライドして具体的な振る舞いを実装してください。

# AIの行動を実行するメソッド
#
# このメソッドは Dungeon クラスから敵ターン時に呼び出されます。
#
# @param dungeon: 現在のダンジョンコンテキスト
# @param entity: このAIを持つエンティティ
func perform(dungeon: Dungeon, entity: Entity) -> void:
    # デフォルトでは何もしない（WaitAction相当）
    pass

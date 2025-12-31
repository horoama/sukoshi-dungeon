class_name TurnManager
extends Node

# ターン管理を行うクラス
#
# プレイヤーと敵のターン遷移を管理し、各状態の開始時・終了時に
# 登録されたコールバック関数を実行します。

enum TurnState {
    PLAYER_TURN,
    ENEMY_TURN
}

var current_state: TurnState = TurnState.PLAYER_TURN

# ターン開始時・終了時のシグナル
signal turn_started(state: TurnState)
signal turn_ended(state: TurnState)

# 自動実行処理（フック）を保持する配列
# キー: state (TurnState), 値: { "pre": [Callable], "post": [Callable] }
var _hooks: Dictionary = {}

func _init():
    # フック辞書の初期化
    for state in TurnState.values():
        _hooks[state] = {
            "pre": [],
            "post": []
        }

# 特定のターンの前後に実行する処理を登録する
#
# @param state: 対象のターン状態
# @param timing: "pre" (開始前) または "post" (終了後)
# @param callback: 実行するCallable
func register_callback(state: TurnState, timing: String, callback: Callable) -> void:
    if not timing in ["pre", "post"]:
        push_error("Invalid timing for turn callback: " + timing)
        return

    if not _hooks.has(state):
        _hooks[state] = { "pre": [], "post": [] }

    _hooks[state][timing].append(callback)

# 状態を変更し、フックを実行する
#
# 現在の状態の post フックを実行 -> 状態変更 -> 新しい状態の pre フックを実行
#
# @param new_state: 遷移先の状態
func change_state(new_state: TurnState) -> void:
    if current_state == new_state:
        return

    # 現在の状態の終了処理
    _execute_hooks(current_state, "post")
    turn_ended.emit(current_state)

    # 状態更新
    current_state = new_state

    # 新しい状態の開始処理
    _execute_hooks(current_state, "pre")
    turn_started.emit(current_state)

# 登録されたフックを実行する内部関数
func _execute_hooks(state: TurnState, timing: String) -> void:
    if _hooks.has(state) and _hooks[state].has(timing):
        for callback in _hooks[state][timing]:
            if callback.is_valid():
                callback.call()

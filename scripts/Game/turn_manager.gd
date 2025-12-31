class_name TurnManager
extends Node

# ターン管理を行うクラス
#
# プレイヤーと敵のターン遷移を管理します。
# 各状態の開始時・終了時にシグナルを発行するため、
# 外部のシステムはそれを利用して処理を行ってください。

enum TurnState {
    PLAYER_TURN,
    ENEMY_TURN
}

var current_state: TurnState = TurnState.PLAYER_TURN

# ターン開始時・終了時のシグナル
signal turn_started(state: TurnState)
signal turn_ended(state: TurnState)

# 状態を変更する
#
# 現在の状態の turn_ended シグナルを発行 -> 状態更新 -> 新しい状態の turn_started シグナルを発行
#
# @param new_state: 遷移先の状態
func change_state(new_state: TurnState) -> void:
    if current_state == new_state:
        return

    Loggie.debug("Turn changing: " + str(current_state) + " -> " + str(new_state))

    # 現在の状態の終了通知
    turn_ended.emit(current_state)

    # 状態更新
    current_state = new_state

    # 新しい状態の開始通知
    turn_started.emit(current_state)

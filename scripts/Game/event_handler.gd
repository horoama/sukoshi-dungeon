class_name EventHandler
extends Node
# プレイヤーの入力を処理し、対応するアクションを生成するクラス
#
# キー入力（矢印キー、WASD、決定キーなど）を監視し、
# それに応じた Action オブジェクト（MovementAction, InteractActionなど）を返します。

# ターン管理への参照
var turn_manager: TurnManager

# 現在の入力状態に基づいてアクションを取得する関数
#
# 押されたキーに対応するアクションオブジェクトを生成して返します。
# 複数のキーが押された場合、if-elifの順序に従って優先順位が決まります。
#
# @return: 生成されたActionオブジェクト。入力がない場合はnull。
func get_action() -> Action:
    # プレイヤーのターンでない場合は入力を受け付けない
    if turn_manager and turn_manager.current_state != TurnManager.TurnState.PLAYER_TURN:
        return null

    var action: Action = null

    if Input.is_action_just_pressed("move_up"):
        action = MovementAction.new(0, -1)
    elif Input.is_action_just_pressed("move_down"):
        action = MovementAction.new(0, 1)
    elif Input.is_action_just_pressed("move_left"):
        action = MovementAction.new(-1, 0)
    elif Input.is_action_just_pressed("move_right"):
        action = MovementAction.new(1, 0)
    elif Input.is_action_just_pressed("interact"):
        # コンテキストに応じたインタラクション: InteractActionが実行時に決定する
        action = InteractAction.new()
    elif Input.is_action_just_pressed("open_inventory"):
        action = OpenInventoryAction.new()
    elif Input.is_action_just_pressed("wait"):
        pass

    if action:
        Loggie.debug("Action generated: " + str(action))
    return action

class_name EventHandler
extends Node


func get_action() -> Action:
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
		# 階段アクションを生成する際は文字列ではなく enum を渡す
		action = StairAction.new(Enum.StairDirection.DOWN)
	return action
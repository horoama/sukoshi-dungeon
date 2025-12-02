class_name GameMenu
extends Control

@export var tabs : TabContainer
@export var inventory_tab : TabBar

const TAB_INDEX = 0

func _ready() -> void:
    visible = false
    SignalBus.open_inventory.connect(open_inventory_tab)
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# if pressed "ui_back", close the menu
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.is_action_pressed("ui_back") and visible:
            visible = false
            get_tree().paused = false

func open_inventory_tab() -> void:
    visible = true
    get_tree().paused = true
    
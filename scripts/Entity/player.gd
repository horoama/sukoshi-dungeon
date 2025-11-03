extends Node

@export var sprite : Node2D

var grid_position: Vector2i

# 移動したシグナル
signal player_moved(pos: Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func move_to_xy(x: int, y: int) -> void:
    move_to(Vector2i(x, y))

func move_to(pos: Vector2i) -> void:
    grid_position = pos
    player_moved.emit(grid_position)

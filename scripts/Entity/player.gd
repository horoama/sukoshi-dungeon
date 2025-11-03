extends Node

@export var sprite : Node2D

var grid_position: Vector2i

# 移動したシグナル
signal player_moved(pos: Vector2i)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func tile() -> Tile:
    # get map_data
    var dungeon = get_node("/root/Dungeon")
    var map_data = dungeon.current_dungeon_map
    return map_data.get_tile(grid_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func move_to_xy(x: int, y: int) -> void:
    move_to(Vector2i(x, y))

func move_to(pos: Vector2i) -> void:
    # get map_data
    var dungeon = get_node("/root/Dungeon")
    var map_data = dungeon.current_dungeon_map
    if map_data.is_passable(pos.x, pos.y) or true:
        grid_position = pos
        print("grid pos: ", grid_position)
        # move sprite
        sprite.position = dungeon.tile_to_local(grid_position)
        
    else:
        print("移動できません")
        return
    player_moved.emit(grid_position)

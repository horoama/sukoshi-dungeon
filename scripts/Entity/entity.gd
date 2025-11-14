class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

var grid_position: Vector2i:
    set(value):
        grid_position = value
        position = map_data.tile_to_local(grid_position)

var _definition: EntityDefinition
var entity_name: String
var passable : bool = false
var ai_type: AIType = AIType.NONE
var entity_type: EntityType = EntityType.ACTOR
var map_data: MapData

var fighter_component: FighterComponent


func _init(map_data: MapData, grid_position: Vector2i, entity_definition: EntityDefinition) -> void:
    centered = false
    flip_h = true
    self.map_data = map_data
    self.grid_position = grid_position
    set_entity_type(entity_definition)

func set_entity_type(entity_definition: EntityDefinition) -> void:
    _definition = entity_definition
    entity_name = entity_definition.name
    texture = entity_definition.texture
    if entity_definition.fighter_definition:
        fighter_component = FighterComponent.new(entity_definition.fighter_definition)
        add_child(fighter_component)


func move(offset: Vector2i) -> void:
    # TODO: entityが存在していた場所がpasssibleだったかの確認は必要かも
    # TODO: 移動先についてもentity自体がpassibleか見る必要あり
    # TODO: map_data上にentityも置いてpassibleかのチェックをした方がよさそう
    map_data.get_tile(grid_position).passable = true
    grid_position += offset
    map_data.get_tile(grid_position).passable = false

class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

const entity_types = {
    "player" : "res://assets/definition/entity/actor/entity_definition_player.tres",
    "rice_ball" : "res://assets/definition/entity/item/entity_definition_rice_ball.tres",
}
var key: String

var grid_position: Vector2i:
    set(value):
        grid_position = value
        position = map_data.tile_to_local(grid_position)

var _definition: EntityDefinition
var entity_name: String
var passable : bool = false
var transparent : bool = true
var ai_type: AIType = AIType.NONE
var entity_type: EntityType = EntityType.ACTOR

# Entityは所属するMapDataを知っている必要がある
var map_data: MapData

var fighter_component: FighterComponent


func _init(map_data: MapData, grid_position: Vector2i, key: String) -> void:
    centered = false
    flip_h = true
    self.map_data = map_data
    self.grid_position = grid_position
    set_entity_type(key)
    map_data.add_entity(grid_position, self)

func set_entity_type(key : String) -> void:
    self.key = key
    print("Creating entity of type: %s" % key)
    var entity_definition: EntityDefinition = load(entity_types[key])
    _definition = entity_definition
    entity_name = entity_definition.name
    texture = entity_definition.texture
    passable = entity_definition.passable
    transparent = entity_definition.transparent
    entity_type = entity_definition.type
    if entity_definition.fighter_definition:
        fighter_component = FighterComponent.new(entity_definition.fighter_definition)
        add_child(fighter_component)


func move(offset: Vector2i) -> void:
    # TODO: entityが存在していた場所がpasssibleだったかの確認は必要かも
    # TODO: 移動先についてもentity自体がpassibleか見る必要あり
    # TODO: map_data上にentityも置いてpassibleかのチェックをした方がよさそう
    if not map_data.is_passable(grid_position + offset):
        return
    map_data.remove_entity(grid_position, self)
    grid_position += offset
    map_data.add_entity(grid_position, self)

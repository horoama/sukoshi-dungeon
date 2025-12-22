class_name EntityFactory
extends RefCounted

const entity_types = {
    "player" : "res://assets/definition/entity/actor/entity_definition_player.tres",
    "rice_ball" : "res://assets/definition/entity/item/entity_definition_rice_ball.tres",
}

static func create(key: String, map_data: MapData, grid_position: Vector2i) -> Entity:
    var entity = Entity.new(map_data, grid_position, key)
    # The _init in Entity calls set_entity_type which loads the resource.
    # Ideally, Entity shouldn't know about the dictionary.
    return entity

static func get_definition_path(key: String) -> String:
    if entity_types.has(key):
        return entity_types[key]
    return ""

class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

var key: String

var grid_position: Vector2i:
    set(value):
        grid_position = value
        if map_data:
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
var inventory_component: InventoryComponent


func _init(map_data: MapData, grid_position: Vector2i, key: String) -> void:
    centered = false
    flip_h = true
    self.map_data = map_data
    self.grid_position = grid_position
    _initialize_from_key(key)
    map_data.add_entity(grid_position, self)

func _initialize_from_key(key: String) -> void:
    self.key = key
    var definition_path = EntityFactory.get_definition_path(key)
    if definition_path != "":
        var entity_definition: EntityDefinition = load(definition_path)
        _initialize_from_definition(entity_definition)

func _initialize_from_definition(entity_definition: EntityDefinition) -> void:
    _definition = entity_definition
    entity_name = entity_definition.name
    name = entity_name
    texture = entity_definition.texture
    passable = entity_definition.passable
    transparent = entity_definition.transparent
    entity_type = entity_definition.type

    _setup_components(entity_definition)

func _setup_components(entity_definition: EntityDefinition) -> void:
    if entity_definition.fighter_definition:
        fighter_component = FighterComponent.new(entity_definition.fighter_definition)
        add_child(fighter_component)
    if entity_definition.inventory_capacity > 0:
        inventory_component = InventoryComponent.new(entity_definition.inventory_capacity)
        add_child(inventory_component)

func move(offset: Vector2i) -> void:
    # TODO: entityが存在していた場所がpasssibleだったかの確認は必要かも
    # TODO: 移動先についてもentity自体がpassibleか見る必要あり
    # TODO: map_data上にentityも置いてpassibleかのチェックをした方がよさそう
    if not map_data.is_passable(grid_position + offset):
        Loggie.info("Cannot move to %s; not passable." % (grid_position + offset))
        return
    map_data.remove_entity(grid_position, self)
    grid_position += offset
    map_data.add_entity(grid_position, self)

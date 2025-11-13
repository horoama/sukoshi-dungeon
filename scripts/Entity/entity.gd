class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = map_data.tile_to_local(grid_position)

var entity_name: String
var passable : bool = false
var ai_type: AIType = AIType.NONE
var entity_type: EntityType = EntityType.ACTOR
var map_data: MapData

var components: Dictionary = {}

func _init(map_data: MapData, grid_position: Vector2i, entity_definition: EntityDefinition) -> void:
	centered = false
	flip_h = true
	self.map_data = map_data
	self.grid_position = grid_position
	self.texture = entity_definition.texture
	self.entity_name = entity_definition.name

func get_component(component_name: String) -> Component:
	return components[component_name]

func add_component(component_name: String, component: Component) -> void:
	components[component_name] = component
	add_child(component)

func move(offset: Vector2i) -> void:
    # TODO: entityが存在していた場所がpasssibleだったかの確認は必要かも
    # TODO: 移動先についてもentity自体がpassibleか見る必要あり
    # TODO: map_data上にentityも置いてpassibleかのチェックをした方がよさそう
	map_data.get_tile(grid_position).passable = true
	grid_position += offset
	map_data.get_tile(grid_position).passable = alse

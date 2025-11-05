class_name Entity
extends Sprite2D

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

var grid_position: Vector2i

var entity_name: String
var passable : bool = false
var ai_type: AIType = AIType.NONE
var entity_type: EntityType = EntityType.ACTOR

var components: Dictionary = {}

func _init() -> void:
    pass

func get_component(component_name: String) -> Component:
    return components[component_name]

func add_component(component_name: String, component: Component) -> void:
    components[component_name] = component
    add_child(component)

func move_to(new_position: Vector2i) -> void:
    grid_position = new_position

func get_map_data() -> MapData:
    var dungeon = get_node("/root/Dungeon")
    return dungeon.current_dungeon_map
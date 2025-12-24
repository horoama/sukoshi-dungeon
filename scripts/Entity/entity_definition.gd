class_name EntityDefinition
extends Resource

@export_category("Visuals")
@export var name: String = "Unnamed Entity"
@export var description: String = ""
@export var texture: AtlasTexture
@export_color_no_alpha var color: Color = Color.WHITE

@export_category("Mechanics")
@export var passable: bool = false
@export var transparent: bool = true
@export var type: Entity.EntityType

@export_category("Components")
@export var fighter_definition: FighterComponentDefinition
@export var consumable_definition: ConsumableComponentDefinition
@export var inventory_capacity: int = 0
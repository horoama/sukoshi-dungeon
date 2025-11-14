class_name FighterComponentDefinition
extends Resource

@export_category("Stats")
@export var max_hp: int
@export var base_defense: int
@export var base_power: int

@export_category("Visuals")
#@export var death_texture: AtlasTexture = preload("res://assets/resources/default_death_texture.tres")
@export var death_color: Color = Color.DARK_RED
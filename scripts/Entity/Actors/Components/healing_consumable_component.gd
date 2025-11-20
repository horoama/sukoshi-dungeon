class_name HealingConsumableComponent
extends ConsumableComponent

var amount: int


func _init(definition: HealingConsumableComponentDefinition) -> void:
	amount = definition.healing_amount


func activate(action: ItemAction) -> bool:
	var consumer: Entity = action.entity
	var amount_recovered: int = consumer.fighter_component.heal(amount)
	if amount_recovered > 0:
		MessageContainer.send_message("Your wounds feel better! You recover %d HP." % amount_recovered, )
		return true
	return false
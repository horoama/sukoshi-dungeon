class_name InventoryComponent
extends Component

var items: Array[Entity]
var capacity: int

func _init(capacity: int) -> void:
    self.capacity = capacity
    items = []

func drop(item: Entity) -> void:
    items.erase(item)
    var map_data = self.get_map_data()
    item.map_data = map_data
    item.grid_position = entity.grid_position
    map_data.add_entity(item.grid_position, item)
    entity.get_parent().add_child(item)
    # TODO: message

func add_item(item: Entity) -> bool:
    if items.size() >= capacity:
        Loggie.error("Cannot add item %s to inventory: capacity reached." % item.name)
        return false
    items.append(item)
    Loggie.info("Item %s added to inventory." % item.name)
    return true

func can_add_item(item: Entity) -> bool:
    # TODO: consider item size/weight
    return items.size() < capacity
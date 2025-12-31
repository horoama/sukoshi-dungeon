class_name Inventory
extends Control
# プレイヤーのインベントリUIを管理するクラス
#
# 所持アイテムのリストを表示し、更新を反映します。

@onready var item_list_container : BoxContainer = $InventoryListScrollContainer/ItemListContainer
@onready var items : Array[Entity] = []

@export var item_scene : PackedScene

func _ready() -> void:
    SignalBus.update_player_inventory.connect(_on_update_player_inventory)

# インベントリ更新シグナルのハンドラ
#
# SignalBusからアイテムリストを受け取り、UI表示を更新します。
#
# @param item_list: 更新されたアイテム（Entity）のリスト
func _on_update_player_inventory(item_list: Array[Entity]) -> void:
    items = item_list
    _refresh_inventory_display()

# インベントリ表示をリフレッシュする内部関数
#
# 現在のアイテムリストに基づいて、UI要素（リスト項目）を再生成します。
func _refresh_inventory_display() -> void:
    # 既存のリスト項目を削除
    for child in item_list_container.get_children():
        item_list_container.remove_child(child)
        child.queue_free()

    # 新しいリスト項目を追加
    for item in items:
        var item_entry = item_scene.instantiate()
        item_entry.get_node("ItemName").text = item.name
        item_entry.get_node("ItemIcon").texture = item.texture
        item_list_container.add_child(item_entry)

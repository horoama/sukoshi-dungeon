extends Node

signal actor_took_damage(actor, damage)
signal player_died()
signal message_sent(message, color)
signal update_player_inventory(item_list)
signal item_used(inventory_item: Entity)
signal open_inventory()
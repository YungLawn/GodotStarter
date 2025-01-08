extends Node


var crosshair: Sprite2D
var player: Node2D
var external_inventory: PanelContainer

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)
	
func get_global_position() -> Vector2:
	return player.global_position

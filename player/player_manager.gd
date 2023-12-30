extends Node

var player

func use_slot_data(slot_data: SlotData) -> void:
	slot_data.item_data.use(player)
	
func get_global_position() -> Vector2:
	return player.global_position

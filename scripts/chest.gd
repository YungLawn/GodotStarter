extends StaticBody2D

signal toggle_inventory(external_inventory_owner)

@export var inventory_data: InventoryData

func player_interact() -> void:
	toggle_inventory.emit(self)
	
func take_damage(damage: float, direction: Vector2):
	print("!!", damage, direction)

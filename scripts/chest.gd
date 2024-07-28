extends StaticBody2D

signal toggle_inventory(external_inventory_owner)

@onready var indicator = $indicator

@export var inventory_data: InventoryData

func player_interact() -> void:
	toggle_inventory.emit(self)
	
func take_damage(damage: float, direction: Vector2):
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(self, "rotation_degrees", rotation_degrees, 0.05).from(rotation_degrees + randf_range(-20, 20))
	tween.tween_property(self, "modulate", modulate, 0.03).from(Color(10, 10, 10, 1)).finished.connect(func(): 
				modulate = Color(1,1,1,1)
				rotation_degrees = 0
				tween.kill()
				)

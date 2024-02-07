extends ItemData
class_name  ItemDataRangedWeapon

@export var damage: int
@export var fire_mode: int
@export var fire_rate: int

func use(target) -> void:
	print(damage)

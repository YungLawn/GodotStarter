extends ItemData

class_name ItemDataWeapon

@export var damage: int
@export var effective_range: float
var can_attack: bool = true
var is_attacking: bool = false

func attack():
	print("grrrr")

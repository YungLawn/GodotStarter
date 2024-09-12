extends ItemData
class_name  ItemDataConsumable

@export var heal_value: int

func use(target) -> void:
	if heal_value != 0:
		heal(target)
		#target.heal(heal_value)
		
func heal(target):
	var random_number = randf_range(-1, 1)
	var tween = target.create_tween().set_parallel(true)
	tween.tween_property(target.held_item, "rotation", target.held_item.rotation + (random_number * 1.5), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(target.main_sprite, "modulate", target.main_sprite.modulate, 0.15).from(Color(2,2,2,1)).set_ease(Tween.EASE_OUT).finished.connect(func() :
		target.main_sprite.modulate = Color(1,1,1,1))
	target.health += heal_value

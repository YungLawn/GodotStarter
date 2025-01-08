extends ItemData
class_name  ItemDataConsumable

@export var heal_value: int
@export var use_time = 0.25
var can_use: bool = true

func use(target) -> void:
	if heal_value != 0 and can_use:
		heal(target)

func heal(target):
	can_use = false
	var random_number = randf_range(-1, 1)
	var tween = target.character.create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(target.character.held_item, "rotation", target.character.held_item.rotation - (target.character.look_direction.normalized().x * 0.5), use_time * 0.5)
	tween.tween_property(target.character.held_item, "rotation", target.character.held_item.rotation, use_time * 0.5).set_delay(use_time * 0.5)
	tween.tween_property(target.character.held_item, "position", (target.character.pivot_point.position + target.character.held_item.position) * 0.5, use_time * 0.5)
	tween.tween_property(target.character.held_item, "position", target.character.held_item.position, use_time * 0.5).set_delay(use_time * 0.5)
	tween.tween_property(target.character.main_sprite, "modulate", target.character.main_sprite.modulate, use_time).from(Color(2,2,2,1)).finished.connect(func() :
		target.character.main_sprite.modulate = Color(1,1,1,1)
		can_use = true
		)

	target.character.health += heal_value

extends ItemData
class_name  ItemDataMeleeWeapon

@export var damage: int
@export var speed: float

var can_swing: bool = true

#var attack_cooldown : Timer = Timer.new()
	#
#func _init():
	#attack_cooldown.one_shot = true
	#attack_cooldown.autostart = false
	#attack_cooldown.timeout.connect(attack_cooldown_timeout)
#
#func attack_cooldown_timeout():
	#can_swing = true

func use(target) -> void:
	if can_swing:
		swing(target)
func swing(target):
	print(target.held_item_data.name)
	var tween = target.create_tween()
	
	can_swing = false
	#tween.tween_property(target.held_item, "rotation", target.held_item.rotation_degrees - 20, 0.2)
	#tween.tween_property(target.held_item, "position", target.held_item.position - Vector2(0,5), 0.2)

	await target.get_tree().create_timer(weight * 0.5).timeout
	can_swing = true



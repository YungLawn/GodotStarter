extends Node2D

class_name projectile

@onready var ray_cast_2d = $RayCast2D
@onready var sprite = $sprite

var velocity: int
var direction: Vector2
var damage: int
var texture: AtlasTexture

func _ready():
	ray_cast_2d.collide_with_areas = true
	pass

func _process(delta):
	var calc_velo: float = velocity * delta * 0.4
	global_position += direction * calc_velo
	ray_cast_2d.target_position.x = calc_velo * 4
	ray_cast_2d.position.x = -calc_velo * 1.5
	await get_tree().create_timer(calc_velo * 0.0025).timeout
	sprite.visible = true
	if ray_cast_2d.is_colliding():
		var target = ray_cast_2d.get_collider()
		#print(target)
		if target.has_method("take_damage"):
			target.take_damage(damage, direction)
		elif target.get_parent().has_method("take_damage"):
			target.get_parent().take_damage(damage, direction)
		queue_free()
		#print(target)

func _on_visible_on_screen_notifier_2d_screen_exited():
	#print("gone")
	queue_free()

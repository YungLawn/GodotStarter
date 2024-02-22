extends Node2D

class_name projectile

@onready var traveling_ray = $traveling_ray
@onready var sprite = $sprite

var velocity: int
var direction: Vector2
var damage: int
var texture: AtlasTexture

func _process(delta):
	var calc_velo: float = velocity * delta * 0.6
	check_collisions(calc_velo, traveling_ray)
	
func hit(target, damage, direction):
	print("hit")
	if target.has_method("take_damage"):
		target.take_damage(damage, direction)
	elif target.get_parent().has_method("take_damage"):
		target.get_parent().take_damage(damage, direction)
		
	queue_free()

func check_collisions(velo: float, ray: RayCast2D):
	global_position += direction * velo
	ray.target_position.x = velo * 3
	#ray.position.x = -velo * 1.5
	await get_tree().create_timer(velo * 0.00125).timeout
	sprite.visible = true
	if traveling_ray.is_colliding():
		hit(traveling_ray.get_collider(), damage, direction)


func _on_visible_on_screen_notifier_2d_screen_exited():
	#print("gone")
	queue_free()

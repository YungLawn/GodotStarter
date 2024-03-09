extends ItemDataWeapon
class_name  ItemDataRangedWeapon

const MUZZLE_FLASH = preload("res://assets/FX/GPU_muzzle_flash.tscn")
const PROJECTILE = preload("res://inventory_system/item/items/weapons/ranged/projectile.tscn")

@export var fire_mode: int
@export var fire_rate: int
@export var muzzle_velocity: int
@export var max_capacity: int
@export var current_capacity: int
@export var accuracy: float
@export var reload_time: float

@export var recoil_strength: Vector2
@export var muzzle_flash_offset: float
@export var ammo_sprite: AtlasTexture

var projectile: projectile
var muzzle_flash: GPUParticles2D
var can_reload: bool = true

func use(target) -> void:
	if can_attack:
		shoot(target)

func reload(target):
	if current_capacity < max_capacity and can_reload:
		#print(target.held_item.flip_h, target.held_item.flip_v)
		var reload_rotation_degrees = target.held_item.rotation_degrees - 360
		var reload_multiplier = 0.5
		can_reload = false
		can_attack = false
		var tween = target.create_tween()
		tween.tween_property(target.held_item, "rotation_degrees", reload_rotation_degrees, reload_time * reload_multiplier).set_ease(Tween.EASE_OUT_IN)
		await target.get_tree().create_timer(reload_time * reload_multiplier).timeout
		current_capacity = max_capacity
		can_attack = true
		can_reload = true

func shoot(target):
	var fire_rate_time = abs((fire_rate - 1500) * (0.00015 if fire_mode == 2 else 0.00025))
	print(fire_rate_time)
	var ranged_recoil = target.lookDirection.normalized() * recoil_strength.x
	var back_stop = target.lookDirection.normalized() * hold_distance * 0.5
	var muzzle_climb = 0.15 * recoil_strength.y
	var tween = target.create_tween()
	tween.set_parallel(true)

	if current_capacity <= 0:
		return
	else:
		target.weapon_fired()
		can_attack = false
		can_reload = false
		current_capacity -= 1
		
		projectile = PROJECTILE.instantiate()
		target.get_tree().root.add_child(projectile)
		muzzle_flash = MUZZLE_FLASH.instantiate()
		target.get_tree().root.add_child(muzzle_flash)
		
		tween.tween_property(target.held_item, "rotation", target.held_item.rotation, 0.15).from(
			 target.held_item.rotation + 
				(muzzle_climb if target.lookDirection.normalized().x < 0 else -muzzle_climb))
		
		tween.tween_property(target.held_item, "position", target.held_item.position, 0.15).from(
			target.held_item.position - ranged_recoil )
		
		muzzle_flash.position = target.attack_effect_spawn_point.global_position
		muzzle_flash.rotation = target.projectile_spawn_point.rotation
		muzzle_flash.amount = (recoil_strength.x) * 5
		muzzle_flash.process_material.scale_max = (recoil_strength.x) * 0.25
		muzzle_flash.process_material.initial_velocity_max = (recoil_strength.x) * 75
		muzzle_flash.emitting = true
		muzzle_flash.finished.connect(func (): muzzle_flash.queue_free() )
		
		#var projectile_spawn_point = target.lookDirection.normalized() * target.global_position
		projectile.global_position = target.attack_effect_spawn_point.global_position 
		projectile.sprite.texture = ammo_sprite
		projectile.rotation = target.projectile_spawn_point.rotation
		var aim_point2: Vector2 = target.attack_effect_spawn_point.global_position
		var aim_point1: Vector2 = target.get_global_mouse_position()
		projectile.accuracy = accuracy * 0.01
		projectile.direction = target.projectile_spawn_point.global_position.direction_to(aim_point2)
		projectile.damage = damage
		projectile.velocity = muzzle_velocity
		
		if target.ranged_ray.is_colliding():
			projectile.hit(target.ranged_ray.get_collider(), damage, projectile.direction)

		await target.get_tree().create_timer(fire_rate_time).timeout
		can_attack = true
		can_reload = true
			
		if fire_mode == 2:
			if target.is_pressed:
				use(target)


extends ItemDataWeapon
class_name  ItemDataRangedWeapon

const MUZZLE_FLASH = preload("res://assets/FX/GPU_muzzle_flash.tscn")
const PROJECTILE = preload("res://inventory_system/item/items/weapons/ranged/projectile.tscn")
const SMOKE = preload("res://assets/FX/smoke.tscn")

@export var fire_mode: int
@export var fire_rate: int
@export var projectiles_per_shot: int = 1
@export var muzzle_velocity: int
@export var max_capacity: int
@export var current_capacity: int
@export var accuracy: float
@export var reload_time: float

@export var ejects_casing: bool
@export var recoil_strength: Vector2
@export var muzzle_flash_offset: float
@export var ammo_sprite: AtlasTexture

#var projectile: projectile
#var muzzle_flash: GPUParticles2D
var can_reload: bool = true
var is_reloading: bool = false

func use(target) -> void:
	#print(target.get_node("BaseSprite").get_node("held_item"))
	if can_attack:
		shoot(target)

func reload(target, direction_modifier):
	if current_capacity < max_capacity and can_reload:
		#print(target.held_item.flip_h, target.held_item.flip_v)
		#var reload_rotation_degrees = target.held_item.rotation_degrees + 90
		var reload_multiplier = 0.5
		can_reload = false
		can_attack = false
		is_reloading = true
		var tween = target.create_tween()
		tween.tween_property(target.held_item, "rotation_degrees", target.held_item.rotation_degrees - (360 * direction_modifier), reload_time * reload_multiplier).set_ease(Tween.EASE_OUT_IN)
		await target.get_tree().create_timer(reload_time * reload_multiplier).timeout
		current_capacity = max_capacity
		can_attack = true
		can_reload = true
		is_reloading = false

func shoot(target):
	var fire_rate_time = abs((fire_rate - 1500) * (0.00015 if fire_mode == 2 else 0.00025))
	#print(fire_rate_time)

	if current_capacity <= 0:
		return
	else:
		can_attack = false
		can_reload = false
		is_attacking = true
		current_capacity -= 1

		var muzzle_flash = MUZZLE_FLASH.instantiate()
		target.held_item.add_child(muzzle_flash)
		muzzle_flash.global_position = target.attack_effect_spawn_point.global_position
		#muzzle_flash.rotation = target.projectile_spawn_point.rotation
		muzzle_flash.amount = (recoil_strength.x) * 5
		muzzle_flash.process_material.scale_max = (recoil_strength.x) * 0.25
		muzzle_flash.process_material.initial_velocity_max = (recoil_strength.x) * 75
		muzzle_flash.emitting = true
		muzzle_flash.finished.connect(func (): muzzle_flash.queue_free() )
		
		var smoke = SMOKE.instantiate()
		target.held_item.add_child(smoke)
		smoke.global_position = target.attack_effect_spawn_point.global_position
		#smoke.rotation = target.held_item.rotation
		smoke.amount = (target.held_item_data.recoil_strength.x) * 2
		smoke.process_material.scale_max = (target.held_item_data.recoil_strength.x)
		smoke.process_material.initial_velocity_max = (target.held_item_data.recoil_strength.x) * 10
		smoke.emitting = true
		smoke.finished.connect(func (): smoke.queue_free() )
		
		for i in projectiles_per_shot :
			var projectile = PROJECTILE.instantiate()
			target.get_tree().root.add_child(projectile)
			projectile.global_position = target.projectile_spawn_point.global_position 
			projectile.sprite.texture = ammo_sprite
			projectile.rotation = target.held_item.rotation
			projectile.accuracy = accuracy
			target.attack_effect_spawn_point.position.y += randf_range(-100 + accuracy, 100 - accuracy) * 0.01
			projectile.direction = target.projectile_spawn_point.global_position.direction_to(target.attack_effect_spawn_point.global_position)
			projectile.damage = damage
			projectile.velocity = muzzle_velocity
		
			#if target.ranged_ray.is_colliding():
				#projectile.hit(target.ranged_ray.get_collider(), damage, projectile.direction)

		animate_shoot(target, target.held_item)
		
		await target.get_tree().create_timer(fire_rate_time).timeout
		can_attack = true
		can_reload = true
		is_attacking = false
			
		if fire_mode == 2:
			if target.is_pressed:
				shoot(target)

func animate_shoot(target, item):
	var aim_point = (Crosshair.global_position - item.global_position).normalized()
	var ranged_recoil = aim_point * recoil_strength.x
	var muzzle_climb = 0.1 * recoil_strength.y
	var tween = target.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	tween.tween_property(item, "rotation", item.rotation, 0.15).from(
		 item.rotation + (muzzle_climb if aim_point.x < 0 else -muzzle_climb))
	
	tween.tween_property(item, "position", item.position, 0.15).from(
		item.position - ranged_recoil )

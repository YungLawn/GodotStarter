extends ItemData
class_name  ItemDataRangedWeapon

const BULLET = preload("res://inventory_system/item/items/ranged/bullet.tscn")
#const MUZZLE_FLASH = preload("res://assets/icons/muzzle_flash.tscn")
const MUZZLE_FLASH = preload("res://assets/icons/GPU_muzzle_flash.tscn")

@export var damage: int
@export var fire_mode: int
@export var fire_rate: int
@export var recoil_strength: float
@export var max_capacity: int
@export var current_capacity: int
@export var muzzle_velocity: int
@export var muzzle_flash_offset: float
@export var reload_time: float

var attack_cooldown : Timer = Timer.new()

var bullet: bullet
var muzzle_flash: GPUParticles2D
var can_fire: bool = true
var can_reload: bool = true

func _init():
	attack_cooldown.one_shot = true
	attack_cooldown.autostart = false
	attack_cooldown.timeout.connect(attack_cooldown_timeout)
	
func attack_cooldown_timeout():
	can_fire = true
	can_reload = true

func use(target) -> void:
	if can_fire:
		shoot(target)

func reload(target):
	can_fire = false
	if current_capacity < max_capacity and can_reload:
		#print(target.held_item.flip_h, target.held_item.flip_v)
		var reload_rotation_degrees = target.held_item.rotation_degrees - 360
		var reload_multiplier = 0.5
		can_reload = false
		var tween = target.create_tween()
		tween.tween_property(target.held_item, "rotation_degrees", reload_rotation_degrees, reload_time * reload_multiplier).set_ease(Tween.EASE_OUT_IN)
		await target.get_tree().create_timer(reload_time * reload_multiplier).timeout
		current_capacity = max_capacity
		can_fire = true
		can_reload = true

func shoot(target):
	var fire_rate_time = abs((fire_rate - 1500) * 0.00015)
	var ranged_recoil = target.lookDirection.normalized() * (recoil_strength * 2)
	var muzzle_climb = 0.15 * recoil_strength
	var tween = target.create_tween()
	attack_cooldown.wait_time = fire_rate_time

	if current_capacity <= 0:
		return
	else:
		target.weapon_fired()
		target.get_tree().root.add_child(attack_cooldown)
		attack_cooldown.start()
		can_fire = false
		can_reload = false
		current_capacity -= 1
		
		bullet = BULLET.instantiate()
		target.get_tree().root.add_child(bullet)
		muzzle_flash = MUZZLE_FLASH.instantiate()
		target.get_tree().root.add_child(muzzle_flash)
		
		muzzle_flash.position = target.projectile_spawn_point.global_position
		muzzle_flash.rotation = target.projectile_spawn_point.rotation
		muzzle_flash.amount = (recoil_strength * (muzzle_velocity * 0.5)) * 0.008
		#muzzle_flash.scale_amount_max = (recoil_strength * muzzle_velocity) * 0.003
		#muzzle_flash.initial_velocity_max = (recoil_strength * muzzle_velocity) * 0.25
		muzzle_flash.process_material.scale_max = (recoil_strength * muzzle_velocity) * 0.0005
		muzzle_flash.process_material.initial_velocity_max = (recoil_strength * muzzle_velocity) * 0.1
		muzzle_flash.emitting = true
		
		bullet.global_position = target.projectile_spawn_point.global_position
		bullet.rotation = target.projectile_spawn_point.rotation
		#bullet.rotation_degrees = rad_to_deg(target.get_angle_to(target.get_global_mouse_position()))
		bullet.direction = target.projectile_spawn_point.global_position.direction_to(target.get_global_mouse_position())
		#print(target.projectile_spawn_point.global_position.direction_to(target.get_global_mouse_position()).normalized())
		bullet.damage = damage
		bullet.speed = muzzle_velocity * 0.015
		
		tween.tween_property(target.held_item, "rotation", target.held_item.rotation + 
		(muzzle_climb if target.lookDirection.normalized().x < 0 else -muzzle_climb), 0.05).set_ease(Tween.EASE_OUT)
		tween.tween_property(target.held_item, "position", target.held_item.position - ranged_recoil, 0.05).set_ease(Tween.EASE_OUT)
		
		#target.smoke_trail.emitting = false
		
		if fire_mode == 2:
			await target.get_tree().create_timer(fire_rate_time).timeout
			if Input.is_action_pressed("left_click"):
				use(target)


extends CharacterBody2D

const BLOOD_SPLATTER = preload("res://assets/FX/blood_splatter.tscn")
@onready var base_sprite = $BaseSprite
@onready var health = $health

@export var SPEED: int
@export var SPRINTMULTIPLIER: float
@export var max_health: float
@export var current_health: float
@export var is_chasing = false

@onready var direction: Vector2
@onready var lookDirection: Vector2
@onready var player = $"../player"
@onready var hit_box = $hit_box

var hit_effect: GPUParticles2D

func _ready():
	health.text = str(current_health)

func _physics_process(delta):
	velocity = direction.normalized() * SPEED
	move_and_slide()
	
func _process(delta):
	if is_chasing:
		direction = Vector2(cos(position.angle_to_point(player.position)), sin(position.angle_to_point(player.position))).normalized()
	else: direction = Vector2(0,0)
	lookDirection = position.direction_to(player.position)

	base_sprite.animate(direction, lookDirection)
	
	health.text = str(current_health)
	
#func _on_detection_zone_body_entered(body):
	#if body == player:
		#is_chasing = true

func _on_detection_zone_body_exited(body):
	if body == player:
		is_chasing = false
		
func take_damage(damage: int, direction: Vector2):
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(self, "position", position + (direction * damage * 0.025), 0.05)
	tween.tween_property(self, "rotation_degrees", rotation_degrees, 0.05).from(rotation_degrees + randf_range(-10, 10))
	tween.tween_property(base_sprite, "modulate", base_sprite.modulate, 0.03).from(Color(10, 10, 10, 1))
	
	hit_effect = BLOOD_SPLATTER.instantiate()
	add_child(hit_effect)
	hit_effect.global_position = global_position
	hit_effect.process_material.direction = -Vector3(direction.x, direction.y, 0)
	hit_effect.amount = damage
	hit_effect.emitting = true
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		base_sprite.visible = false
		hit_box.get_child(0).disabled = true
		await get_tree().create_timer(1).timeout
		base_sprite.visible = true
		hit_box.get_child(0).disabled = false
		current_health = max_health

	#print("oof")

extends Camera2D

@export_category("Follow Character")
@export var player: CharacterBody2D

@export_category("Camera Smoothing")
@export var smoothing_enabled: bool
@export_range(1, 10) var smoothing_factor: int = 8

func _physics_process(delta):
	var weight: float
	
	if player != null:
		var camera_pos : Vector2
		
		if smoothing_enabled:
			weight = (11 - smoothing_factor)
			camera_pos = lerp(global_position, player.global_position, delta * weight)
		else:
			camera_pos = player.global_position
			
		global_position = camera_pos

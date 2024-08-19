extends Sprite2D

var distance_to_player: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if PlayerManager.player && is_instance_valid(PlayerManager.player):
		distance_to_player = PlayerManager.player.pivot_point.global_position.distance_to(get_global_mouse_position())
		var direction: Vector2 = (get_global_mouse_position() - PlayerManager.player.pivot_point.global_position).normalized()
		#print(direction)
		if distance_to_player > 30:
			position = lerp(position, get_global_mouse_position(), PlayerManager.player.lerp_strength)
		else:
			position = lerp(position, PlayerManager.player.pivot_point.global_position + (direction) * 30, PlayerManager.player.lerp_strength)
	
#func handle_aim_point(delta, lerp_strength):
	#if targets_in_range:
		#aim_point.global_position = lerp(aim_point.global_position,
			#targets_in_range[locked_target_index].global_position - velocity * held_item_weight * 0.065, 
			#lerp_strength * pow(0.5,2))
	#else:
		#targets_in_range.clear()
		#if held_item_data.has_method("attack"):
			#if held_item_data.has_method("shoot"):
				#if held_item_data.is_reloading:
					#lerp_strength = lerp_strength * 0.01
				##if held_item_data.is_attacking:
					##lerp_strength = lerp_strength * (held_item_data.recoil_strength.x) * 0.2
				#if held_item.position.distance_to(lookDirection) < held_item_data.effective_range:
					#if held_item.position.distance_to(lookDirection) < 40:
						#aim_point.position = lerp(aim_point.position, lookDirection.normalized() * 40  + base_sprite.position, lerp_strength * 0.75)
					#else:
						#aim_point.position = lerp(aim_point.position, lookDirection.normalized() *  held_item.position.distance_to(lookDirection) + base_sprite.position, lerp_strength)
				#else:
					#aim_point.position = lerp(aim_point.position, lookDirection.normalized() * held_item_data.effective_range + base_sprite.position, lerp_strength)
					#
			#elif held_item_data.has_method("swing"):
				#if held_item_data.is_attacking:
					#lerp_strength = lerp_strength * 0
				#aim_point.position = lerp(aim_point.position, lookDirection.normalized() * held_item_data.effective_range + base_sprite.position, lerp_strength)
		#else:
			#aim_point.position = lerp(aim_point.position, lookDirection.normalized() * 20 + base_sprite.position, lerp_strength)

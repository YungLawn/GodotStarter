extends Control

#func _ready():
	#visible = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
	
func _input(event):
		if(event.is_action_pressed("toggle_menu")):
			if visible:
				visible = false
			else: visible = true
			

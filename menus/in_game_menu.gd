extends Control

@onready var world = $"../../World"
@onready var player = get_parent()

func _ready():
	visible = false
	var map_gen = $MarginContainer/VBoxContainer/map_gen_menu
	map_gen.visible = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://menus/main_menu.tscn")
	
func _on_toggle_map_gen_pressed():
	#print(player)
	var map_gen = $MarginContainer/VBoxContainer/map_gen_menu
	if map_gen.visible:
		map_gen.visible = false
	else:
		map_gen.visible = true
	
func _input(event):
		if(event.is_action_pressed("toggle_menu")):
			if visible:
				visible = false
			else: visible = true
			







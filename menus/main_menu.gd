extends VBoxContainer

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/root.tscn")

func _on_quit_pressed():
	get_tree().quit()

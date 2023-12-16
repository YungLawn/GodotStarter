@tool
extends EditorScript

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	var player = get_scene().get_child(1)
	#get_scene().get_child(0).generate_chunk(player.position)
	print("!!!")


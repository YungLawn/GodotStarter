@tool
extends Node

@export var button: bool = false : set = set_button

func set_button(new_value: bool) -> void:
	print("from tool")

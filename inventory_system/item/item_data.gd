extends Resource

class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var rotatable: bool = false
@export var texture: AtlasTexture
@export var offset: Vector2 = Vector2(0,8)
@export var hand_offset: Vector2 = Vector2(0,3) 
@export var hold_distance: float = 10.0
@export var weight: float

func use(_target) -> void:
	pass

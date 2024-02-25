extends Resource

class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var rotatable: bool = false
@export var texture: AtlasTexture
@export var offset: Vector2 
@export var hand_offset: Vector2 
@export var rotation_offset: float
@export var hold_distance: float 
@export var weight: float

func use(_target) -> void:
	pass

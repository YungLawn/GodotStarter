extends Resource

class_name ItemData

@export var name: String = ""
@export_multiline var description: String = ""
@export var stackable: bool = false
@export var rotatable: bool = false
@export var texture: AtlasTexture
@export var offset: Vector2 = Vector2(0,8)

func use(target) -> void:
	pass

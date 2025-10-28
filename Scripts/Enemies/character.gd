extends Node2D
class_name Character

@export var Sprite : Sprite2D
@export var character_attributes : Character_Attributes

var init : bool = false
var pathFollow : PathFollow2D
var path : Path2D
@onready var sprite : Sprite2D = $Sprite2D

func _ready() -> void:
	if Sprite:
		#Sprite.scale = Vector2(0.3, 0.3)
		var size = Sprite.texture.get_size()
		sprite.centered = true
		#sprite.centered = false
		#sprite.offset = Vector2(size.x / 2, size.y)
	else:
		print("Sprite o textura no están disponibles")


func init_path(path : Path2D) -> void:
	pathFollow = PathFollow2D.new()
	pathFollow.add_child(self)
	pathFollow.loop = false
	pathFollow.rotates = false
	path.add_child(pathFollow)


func _physics_process(delta: float) -> void:
	if pathFollow:
		pathFollow.progress += character_attributes.Speed * delta
		if pathFollow.progress_ratio >= 1.0:
			print("end travel")
			pathFollow.queue_free()  # Elimina el contenedor

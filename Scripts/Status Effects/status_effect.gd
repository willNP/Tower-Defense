extends Resource
class_name Status_Effect_Resource

@export var status_name : String
@export var status_duration : float
@export var health_change : float
@export var shader : Shader
@export var texture : Texture2D


func apply_effect(character: Character) -> void:
	# Crear un ShaderMaterial con el shader del recurso
	var mat := ShaderMaterial.new()
	mat.shader = shader
	character.sprite.material = mat

	# Registrar el efecto en el personaje para que lo actualice
	character.add_status_effect(self)

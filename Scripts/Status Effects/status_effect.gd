extends Resource
class_name Status_Effect_Resource

@export var status_name : String
@export var status_duration : float
@export var proc_every : int = 1 # Seconds
@export var shader : Shader

var proc_count : int = 0
var init : bool = false
#@export_group("Health")
#@export var health_modifier : float
#@export var armor_modifier : float
#@export var magic_resistance_modifier : float
#@export var poison_resistance_modifier : float
#@export var fire_resistance_modifier : float
#@export var stun_resistance_modifier : float
#@export var slow_resistance_modifier : float
#
#@export_group("Movement")
#@export var movement_modifier : float
#@export var stop_movement : bool = false

var timer : Timer

func init_timer() -> void:
	if not timer:
		print("entra al timer")
		timer = Timer.new()
		timer.timeout.connect(timer_timeout)
		timer.autostart = false
		timer.one_shot = true
	

func notify_effect(character: Character) -> void:
	init_timer()
	# Crear un ShaderMaterial con el shader del recurso
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("time", status_duration)
	character.sprite.material = mat
	character.add_status_effect(self)
	init = true
	
func timer_timeout():
	pass

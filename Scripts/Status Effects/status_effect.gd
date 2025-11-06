extends Node2D
class_name Status_Effect_Resource

var status_name : String
var status_duration : float
var proc_every : int = 1 # Seconds
var shader : Shader

var character : Character
var proc_count : int = 0
var timer : Timer

func init_timer() -> void:
	if not timer:
		print("entra al timer")
		timer = Timer.new()
		timer.timeout.connect(self.timer_timeout)
		timer.autostart = false
		timer.one_shot = true
		add_child(timer)
	
func set_character(_character : Character) -> void:
	character = _character
	init_timer()
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("time", status_duration)
	character.sprite.material = mat
	print(character.sprite.material)
	character.add_status_effect(self)
	print("character set en el status effect")

func start_timer() -> void:
	if not timer:
		print("timer no inicializado")
	else:
		timer.start(proc_every)	
	
func timer_timeout():
	print("timer timeout")
	

extends Status_Effect_Resource
class_name Poison_Effect

# Inicializar las variables aqui porque no se puede desde el editor
var health_modifier : float 

func _ready() -> void:
	set_process(true)
	status_name = "Poison"
	status_duration = 3.0
	proc_every = 1
	shader = preload("res://Scripts/Status Effects/Shaders/poison_shader.gdshader")
	health_modifier = -15

var poison_time := 0.0

func _process(delta):
	if character.sprite.material and character.sprite.material is ShaderMaterial:
		poison_time += delta
		character.sprite.material.set_shader_parameter("time", poison_time)


func apply_effect() -> void:
	character.receive_dmg(health_modifier, character.character_attributes.poison_resistance)	
	var health = character.character_attributes.health
	var poison_resistance = character.character_attributes.poison_resistance
	var total_damage = health_modifier * (1 - (poison_resistance / (poison_resistance + character.character_attributes.defense_effectiveness)))
	character.character_attributes.health += total_damage
	print("se ha aplicado el veneno, vida actual: ", character.character_attributes.health )
	
	
func timer_timeout():
	print("proc count: ", proc_count)
	print("status duration: ", status_duration)
	proc_count += 1
	if proc_count < status_duration:
		apply_effect()
		timer.start(proc_every)
	else:
		proc_count = 0
		character.sprite.material = null

extends Status_Effect_Resource
class_name Poison_Effect

@export var healt_modifier : float

var character : Character

func notify_effect(_character: Character) -> void:
	if not init:
		super.notify_effect(_character)
	character = _character
	timer.start(proc_every)
	apply_effect()
	
func apply_effect() -> void:
	var health = character.character_attributes.health
	var poison_resistance = character.character_attributes.poison_resistance
	var total_damage = healt_modifier * (1 - (poison_resistance / (poison_resistance + character.character_attributes.defense_effectiveness)))
	character.character_attributes.health += total_damage
	print("se ha aplicado el veneno, vida actual: ", character.character_attributes.health )
	
	
func timer_timeout():
	print(proc_count)
	proc_count += 1
	if proc_count < status_duration:
		apply_effect()
		timer.start(proc_every)
	else:
		proc_count = 0	

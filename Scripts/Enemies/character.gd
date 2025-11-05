extends Node2D
class_name Character

signal died(character: Character)

@export var Sprite : Sprite2D
@export var character_attributes : Character_Attributes

var active_effects : Array[Status_Effect_Resource] = []

var pathFollow : PathFollow2D
var path : Path2D
@onready var sprite : Sprite2D = $Sprite2D

var _is_dead: bool = false



func add_status_effect(effect: Status_Effect_Resource) -> void:
	for eff in active_effects:
		if eff.status_name == effect.status_name:
			effect.proc_count = 0
			return
	active_effects.append(effect)

func init_path(_path : Path2D) -> void:
	pathFollow = PathFollow2D.new()
	pathFollow.add_child(self)
	pathFollow.loop = false
	pathFollow.rotates = false
	_path.add_child(pathFollow)


func _physics_process(delta: float) -> void:
	if pathFollow:
		pathFollow.progress += character_attributes.speed * delta
		if pathFollow.progress_ratio >= 1.0:
			print("end travel")
			self.queue_free()  # Elimina el contenedor


func receive_dmg(dmg_taken : float) -> void:
	if _is_dead:
		return
	if character_attributes.armor == 0:
		character_attributes.health -= dmg_taken
	else:
		# recibido = base * (1 - (armadura / armadura + k)
		var total_damage = calculate_dmg(dmg_taken, character_attributes.armor)
		character_attributes.health -= total_damage
	print(character_attributes.health)	 
	if character_attributes.health <= 0:
		_is_dead = true
		died.emit(self)
		self.queue_free()


func calculate_dmg(incoming_dmg : float, defensive_value : float) -> float:
	return incoming_dmg * (1 - (defensive_value / (defensive_value + character_attributes.defense_effectiveness)))

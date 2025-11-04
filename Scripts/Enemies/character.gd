extends Node2D
class_name Character

signal died(character: Character)

@export var Sprite : Sprite2D
@export var character_attributes : Character_Attributes

var active_effects : Array = []



var init : bool = false
var pathFollow : PathFollow2D
var path : Path2D
@onready var sprite : Sprite2D = $Sprite2D

var _is_dead: bool = false
var _current_health: float = 0.0
var _max_health: float = 0.0


func _ready() -> void:
	if character_attributes:
		_max_health = character_attributes.health
		_current_health = _max_health
	if Sprite:
		#Sprite.scale = Vector2(0.3, 0.3)
		sprite.centered = true
		#sprite.centered = false
		#sprite.offset = Vector2(size.x / 2, size.y)
	else:
		print("Sprite o textura no están disponibles")

func add_status_effect(effect: Status_Effect_Resource) -> void:
	active_effects.append({
		"resource": effect,
		"timer": 0.0
	})


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
			pathFollow.queue_free()  # Elimina el contenedor

func _process(delta: float) -> void:
	for effect_data in active_effects:
		var effect: Status_Effect_Resource = effect_data["resource"]
		effect_data["timer"] += delta
		# Aplicar daño o curación por segundo
		_current_health += effect.health_change * delta
		# Actualizar shader si está activo
		if sprite.material and sprite.material is ShaderMaterial:
			sprite.material.set_shader_parameter("time", effect_data["timer"])
		# Eliminar efecto si terminó
		if effect_data["timer"] >= effect.status_duration:
			active_effects.erase(effect_data)
			sprite.material = null

func receive_dmg(dmg_taken : float) -> void:
	if _is_dead:
		return
	if character_attributes.armor == 0:
		_current_health -= dmg_taken
	else:
		# recibido = base * (1 - (armadura / armadura + k)
		var total_damage = dmg_taken * (1 - (character_attributes.armor / (character_attributes.armor + character_attributes.defense_effectiveness)))
		_current_health -= total_damage
		
	print(_current_health)	 
	if _current_health <= 0:
		_is_dead = true
		died.emit(self)
		self.queue_free()

extends Resource
class_name Character_Attributes

@export_group("Basic attributes")
@export var health : float
@export var speed : float
@export var defense_effectiveness : float

@export_group("Defensives:")
@export var armor : float
@export var magic_resistance : float
@export var poison_resistance : float
@export var fire_resistance : float
@export var stun_resistance : float
@export var slow_resistance : float

@export_group("Offensives:")
@export var attack : float
@export var attack_speed : float
@export var crit_chance : float
@export var hit_chance : float

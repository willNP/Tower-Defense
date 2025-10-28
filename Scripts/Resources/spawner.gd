extends Node2D
class_name Spawner

@export var goblin_amount : int

var grupos : Array[Goblin]

func _ready() -> void:
	var gob = Goblin.new()
		

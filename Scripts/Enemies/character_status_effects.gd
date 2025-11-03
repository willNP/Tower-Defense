extends Node2D
class_name Character_Status_Effects

var timer : Timer

	


func apply_status(character : Character, status : String) -> void:
	match status:
		"POISON":
			pass
		"STUN":
			pass
		"BURN":
			pass
		"SLOW":
			pass
	pass

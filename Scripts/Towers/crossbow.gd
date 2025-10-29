extends Node2D
class_name Crossbow

@export var turretAttributes : Turret_Attributes
@onready var attackTimer : Timer = $AttackSpeedTimer


var arrow_scene := preload("res://Scenes/Towers/Crossbow/crossbow_arrow.tscn")


var hasTarget : bool
var targetList : Array[Character]
var currentTarget : Character

var hasArrow : bool = true

func _ready() -> void:
	attackTimer.wait_time = turretAttributes.attack_speed
	print("attack speed ", turretAttributes.attack_speed)
	


func _physics_process(delta: float) -> void:
	if hasTarget:
		look_at(currentTarget.global_position)



func _on_range_area_area_entered(area: Area2D) -> void:
	if "ENEMY" in area.get_groups():
		targetList.append(area.get_parent())
		if not hasTarget:
			hasTarget = true
			currentTarget = area.get_parent()
		
func _on_range_area_area_exited(area: Area2D) -> void:
	targetList.erase(area.get_parent())
	targetList = targetList.filter(is_instance_valid)
	if hasTarget:
		if targetList.size() > 0:
			# Filtra la lista de acuerdo al que este mas avanzado en el path
			targetList.sort_custom(func(a, b):
				return a.pathFollow.progress_ratio > b.pathFollow.progress_ratio
			)
			currentTarget = targetList[0]
			
		else:
			currentTarget = null
			hasTarget = false


func get_next_target() -> Character:
	var furthest_target : Character = null
	var max_progress := -1.0

	for enemy in targetList:
		var path_follow = enemy.pathFollow
		if path_follow:
			if path_follow.progress_ratio > max_progress:
				max_progress = path_follow.progress_ratio
				furthest_target = enemy
	return furthest_target
	


func _on_attack_speed_timer_timeout() -> void:
	if hasTarget:
		var arrow = arrow_scene.instantiate() as CrossbowArrow
		arrow.global_position = global_position  # desde el centro de la ballesta
		arrow.attack(currentTarget)
		get_tree().root.add_child(arrow)

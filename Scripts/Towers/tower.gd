extends Node2D
class_name Tower

@export var turretAttributes : Turret_Attributes
@export var ammo_scene : PackedScene
@export var area_2d : Area2D

@export_enum("All", "Flying", "Ground") var target_source : String = "All"

@onready var attackTimer : Timer

var hasTarget : bool
var targetList : Array
var currentTarget : Character

func _ready() -> void:
	attackTimer = Timer.new()
	attackTimer.timeout.connect(_on_attack_speed_timer_timeout)
	add_child(attackTimer)
	attackTimer.wait_time = turretAttributes.attack_speed
	area_2d.area_entered.connect(_on_range_area_area_entered)
	area_2d.area_exited.connect(_on_range_area_area_exited)

func _physics_process(_delta: float) -> void:
	if hasTarget:
		if attackTimer.is_stopped():
			attackTimer.start()
		look_at(currentTarget.global_position)

func _on_range_area_area_entered(area: Area2D) -> void:
	if "ENEMY" in area.get_groups():
		if target_source == "All" or target_source in area.get_groups():
			targetList.append(area.get_parent())
			if not hasTarget:
				hasTarget = true
				currentTarget = area.get_parent()
				attackTimer.start()
				disparar()
		
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
	disparar()

func disparar() -> void:
	if hasTarget:
		var ammo = ammo_scene.instantiate()
		ammo.global_position = global_position  # desde el centro de la ballesta
		ammo.attack(currentTarget)
		get_parent().call_deferred("add_child", ammo)

		

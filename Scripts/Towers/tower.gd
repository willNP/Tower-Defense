extends Node2D
class_name Tower

@export var turretAttributes : Turret_Attributes
@export var ammo_scene : PackedScene
@export var area_2d : Area2D
@export var spawn_block_area: Area2D
@export var turret_type: StringName = ""

@export_enum("All", "Flying", "Ground") var target_source : String = "All"
@onready var attackTimer : Timer

@export_group("Status Effect Probabilities")
@export var poison_prob : int
@export var fire_prob : int
@export var stun_prob : int
@export var slow_prob : int

var status_effects : Dictionary = {
	poison = preload("res://Scripts/Status Effects/poison_effect.gd"),
	fire = preload("res://Scripts/Status Effects/fire_effect.gd")
}



var hasTarget : bool
var targetList : Array
var currentTarget : Character
var _range_radius: float = 0.0
var _spawn_block_radius: float = 0.0

func _ready() -> void:
	init_attackTimer()
	if area_2d:
		area_2d.area_entered.connect(_on_range_area_area_entered)
		area_2d.area_exited.connect(_on_range_area_area_exited)
		_range_radius = _extract_area_radius(area_2d)
	if spawn_block_area:
		_spawn_block_radius = _extract_area_radius(spawn_block_area)
	add_to_group("TOWERS")


func init_attackTimer() -> void:
	attackTimer = Timer.new()
	attackTimer.timeout.connect(_on_attack_speed_timer_timeout)
	add_child(attackTimer)
	attackTimer.wait_time = turretAttributes.attack_speed
	
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
		var ammo : Ammo = ammo_scene.instantiate()
		ammo.global_position = global_position  # desde el centro de la ballesta
		ammo.attack(currentTarget)
		get_parent().call_deferred("add_child", ammo)
		var effect = calculate_ammo_effect()
		if effect:
			ammo.effect = effect

func get_turret_type() -> StringName:
	return turret_type

func is_position_within_range(world_position: Vector2) -> bool:
	if _range_radius <= 0.0:
		return false
	var center: Vector2 = area_2d.global_position if area_2d else global_position
	return center.distance_to(world_position) <= _range_radius

func is_position_within_spawn_block(world_position: Vector2) -> bool:
	if spawn_block_area == null or _spawn_block_radius <= 0.0:
		return false
	var center: Vector2 = spawn_block_area.global_position
	return center.distance_to(world_position) <= _spawn_block_radius

func _extract_area_radius(area: Area2D) -> float:
	for child in area.get_children():
		if child is CollisionShape2D:
			var shape: Shape2D = (child as CollisionShape2D).shape
			if shape is CircleShape2D:
				var circle: CircleShape2D = shape as CircleShape2D
				var _scale: Vector2 = (child as CollisionShape2D).global_scale
				var uniform_scale: float = max(abs(_scale.x), abs(_scale.y))
				return circle.radius * uniform_scale
	return 0.0
	
func calculate_ammo_effect() -> Status_Effect_Resource:
	if poison_prob > 0:
		var randomNumber = randi() % 100
		if randomNumber <= poison_prob:
			var poison_instance : Poison_Effect = status_effects.poison.new()
			return poison_instance
	if fire_prob > 0:
		var randomNumber = randi() % 100
		if randomNumber <= fire_prob:
			var fire_instance : Fire_Effect = status_effects.fire.new()
			return fire_instance
		
			
	if fire_prob > 0:
		pass
	if slow_prob > 0:
		pass
	if stun_prob > 0:
		pass
	return null

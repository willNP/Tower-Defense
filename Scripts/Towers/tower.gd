extends Node2D
class_name Tower

const DEFAULT_RANGE_COLOR := Color(0.3, 0.6, 1.0, 0.2)
const DEFAULT_SPAWN_COLOR := Color(1.0, 0.6, 0.4, 0.25)
const PREVIEW_RANGE_COLOR := Color(0.5, 0.8, 0.5, 0.35)
const PREVIEW_INVALID_COLOR := Color(1.0, 0.5, 0.5, 0.35)
const RangeDisplay := preload("res://Scripts/Towers/range_display.gd")

@export var turretAttributes : Turret_Attributes
@export var ammo_scene : PackedScene
@export var area_2d : Area2D
@export var spawn_block_area: Area2D
@export var turret_type: StringName = ""

@export_enum("All", "Flying", "Ground") var target_source : String = "All"

var attackTimer : Timer

var hasTarget : bool
var targetList : Array
var currentTarget : Character
var _range_radius: float = 0.0
var _spawn_block_radius: float = 0.0
var _is_preview: bool = false
var _range_display: RangeDisplay
var _spawn_display: RangeDisplay

func _ready() -> void:
	if area_2d:
		_range_radius = _extract_area_radius(area_2d)
		if _is_preview:
			area_2d.monitoring = false
		else:
			area_2d.area_entered.connect(_on_range_area_area_entered)
			area_2d.area_exited.connect(_on_range_area_area_exited)
	if spawn_block_area:
		_spawn_block_radius = _extract_area_radius(spawn_block_area)
		if _is_preview:
			spawn_block_area.monitoring = false
		else:
			spawn_block_area.visible = false
		_update_spawn_display(DEFAULT_SPAWN_COLOR, false)
	_update_range_display(DEFAULT_RANGE_COLOR if not _is_preview else PREVIEW_RANGE_COLOR)
	if _is_preview:
		return
	attackTimer = Timer.new()
	attackTimer.timeout.connect(_on_attack_speed_timer_timeout)
	add_child(attackTimer)
	attackTimer.wait_time = turretAttributes.attack_speed
	add_to_group("TOWERS")

func _physics_process(_delta: float) -> void:
	if _is_preview:
		return
	if hasTarget:
		if attackTimer.is_stopped():
			attackTimer.start()
		look_at(currentTarget.global_position)

func _on_range_area_area_entered(area: Area2D) -> void:
	if _is_preview:
		return
	if "ENEMY" in area.get_groups():
		if target_source == "All" or target_source in area.get_groups():
			targetList.append(area.get_parent())
			if not hasTarget:
				hasTarget = true
				currentTarget = area.get_parent()
				attackTimer.start()
				disparar()
		
func _on_range_area_area_exited(area: Area2D) -> void:
	if _is_preview:
		return
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
	var max_progress: float = -1.0

	for enemy in targetList:
		var path_follow = enemy.pathFollow
		if path_follow:
			if path_follow.progress_ratio > max_progress:
				max_progress = path_follow.progress_ratio
				furthest_target = enemy
	return furthest_target

func _on_attack_speed_timer_timeout() -> void:
	if _is_preview:
		return
	disparar()

func disparar() -> void:
	if _is_preview:
		return
	if hasTarget:
		var ammo = ammo_scene.instantiate()
		ammo.global_position = global_position  # desde el centro de la ballesta
		ammo.attack(currentTarget)
		get_parent().call_deferred("add_child", ammo)

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
				var scale: Vector2 = (child as CollisionShape2D).global_scale
				var uniform_scale: float = max(abs(scale.x), abs(scale.y))
				return circle.radius * uniform_scale
	return 0.0

func set_preview_mode(enabled: bool) -> void:
	_is_preview = enabled
	if _is_preview:
		modulate = Color(1, 1, 1, 0.5)
		_update_range_display(PREVIEW_RANGE_COLOR)

func is_preview() -> bool:
	return _is_preview

func set_range_color(color: Color) -> void:
	_update_range_display(color)

func reset_range_color() -> void:
	_update_range_display(DEFAULT_RANGE_COLOR)
	if _range_display:
		_range_display.hide()
	hide_spawn_block_indicator()

func _update_range_display(color: Color) -> void:
	if _range_radius <= 0.0:
		return
	if _range_display == null or not is_instance_valid(_range_display):
		_range_display = RangeDisplay.new()
		_range_display.z_index = 100
		_range_display.z_as_relative = false
		_range_display.set_radius(_range_radius)
		_range_display.set_line_width(3.0)
		_range_display.set_filled(false)
		_range_display.set_color(color)
		add_child(_range_display)
	else:
		_range_display.set_radius(_range_radius)
		_range_display.set_color(color)
		_range_display.set_filled(false)
		_range_display.show()

func show_spawn_block_indicator(color: Color) -> void:
	_update_spawn_display(color, true)

func hide_spawn_block_indicator() -> void:
	if _spawn_display and is_instance_valid(_spawn_display):
		_spawn_display.hide()

func _update_spawn_display(color: Color, force_visible: bool) -> void:
	if _spawn_block_radius <= 0.0:
		return
	if _spawn_display == null or not is_instance_valid(_spawn_display):
		_spawn_display = RangeDisplay.new()
		_spawn_display.z_index = 99
		_spawn_display.z_as_relative = false
		_spawn_display.set_radius(_spawn_block_radius)
		_spawn_display.set_line_width(2.0)
		_spawn_display.set_filled(true)
		add_child(_spawn_display)
	_spawn_display.set_radius(_spawn_block_radius)
	_spawn_display.set_color(color)
	_spawn_display.set_filled(true)
	if force_visible:
		_spawn_display.show()
	else:
		_spawn_display.hide()

func show_default_range_indicator() -> void:
	_update_range_display(DEFAULT_RANGE_COLOR)

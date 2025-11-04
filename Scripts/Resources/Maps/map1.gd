extends Node2D
class_name Map_1

@export var enemy_spawn_number : int = 10
@export var starting_gold: int = 100
# Enemies
var enemies = {
	goblin = preload("res://Scenes/Enemies/goblin.tscn"),
	bat = preload("res://Scenes/Enemies/bat.tscn"),
	golem = preload("res://Scenes/Enemies/golem.tscn")
}

const ENEMY_REWARDS := {
	&"goblin": 5,
	&"bat": 7,
	&"golem": 10
}

const TURRET_COSTS := {
	&"cannon": 100,
	&"crossbow": 100
}

const WAVE_INFO_PATH := "UI/Control/WaveInfo"
const ENEMIES_INFO_PATH := "UI/Control/EnemiesInfo"
const GOLD_INFO_PATH := "UI/Control/Panel/GoldInfo"

# Variables
var timer : Timer
var _turret_spawner: TurretSpawner
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

var _current_wave: int = 1
var _current_wave_enemy_target: int = 0
var _spawn_queue: Array[StringName] = []
var _spawn_index: int = 0
var _spawned_this_wave: int = 0
var _enemies_alive: int = 0
var _gold: int = 0

var _wave_label: Label
var _enemies_label: Label
var _gold_label: Label

func _ready() -> void:
	# Crear el Timer
	timer = Timer.new()
	timer.wait_time = 1.2  # Tiempo entre spawns
	timer.autostart = false
	timer.one_shot = false
	add_child(timer)

	# Conectar la señal timeout
	timer.timeout.connect(_on_timer_timeout)

	_rng.randomize()

	_turret_spawner = $TurretSpawner
	_setup_turret_buttons()

	_wave_label = _get_label(WAVE_INFO_PATH)
	_enemies_label = _get_label(ENEMIES_INFO_PATH)
	_gold_label = _get_label(GOLD_INFO_PATH)
	_gold = starting_gold
	_update_gold_ui()

	_current_wave_enemy_target = max(enemy_spawn_number, enemies.size())
	_prepare_wave()

func _on_timer_timeout() -> void:
	if _spawn_index >= _spawn_queue.size():
		timer.stop()
		_update_wave_ui()
		return

	var enemy_type: StringName = _spawn_queue[_spawn_index]
	_spawn_index += 1

	var enemy_scene_variant = enemies.get(enemy_type, null)
	if enemy_scene_variant == null or not (enemy_scene_variant is PackedScene):
		return
	var enemy_scene: PackedScene = enemy_scene_variant
	var enemy_instance : Character = enemy_scene.instantiate()
	var path_node: Path2D = $MapGeneration.get_path_node()
	if path_node:
		enemy_instance.init_path(path_node)
		enemy_instance.path = path_node

	enemy_instance.tree_exited.connect(_on_enemy_removed.bind(enemy_type))
	if enemy_instance.has_signal("died"):
		enemy_instance.died.connect(_on_enemy_killed.bind(enemy_type))

	_spawned_this_wave += 1
	_enemies_alive += 1
	_update_wave_ui()


func _setup_turret_buttons() -> void:
	var buttons_path := "UI/Control/Panel/Buttons"
	if not has_node(buttons_path):
		return

	var cannon_button: Button = $UI/Control/Panel/Buttons/canon
	var crossbow_button: Button = $UI/Control/Panel/Buttons/crossbow

	cannon_button.toggled.connect(func(pressed: bool) -> void:
		if pressed:
			_select_turret("cannon")
	)
	crossbow_button.toggled.connect(func(pressed: bool) -> void:
		if pressed:
			_select_turret("crossbow")
	)

	if cannon_button.toggle_mode:
		cannon_button.button_pressed = true
	_select_turret("cannon")

func _select_turret(turret_name: StringName) -> void:
	if _turret_spawner:
		_turret_spawner.set_selected_turret(turret_name)

func _prepare_wave() -> void:
	timer.stop()
	_spawn_queue = _build_spawn_queue(_current_wave_enemy_target)
	_spawn_index = 0
	_spawned_this_wave = 0
	_enemies_alive = 0

	_update_wave_ui()
	if _spawn_queue.is_empty():
		return

	print("Oleada %d: %d enemigos" % [_current_wave, _current_wave_enemy_target])
	timer.start()

func _on_enemy_removed(_enemy_type: StringName) -> void:
	_enemies_alive = max(0, _enemies_alive - 1)
	_update_wave_ui()
	if _enemies_alive == 0 and _spawned_this_wave >= _current_wave_enemy_target:
		print("Oleada %d completada" % _current_wave)
		_advance_wave()

func _on_enemy_killed(_enemy: Character, enemy_type: StringName) -> void:
	var reward: int = int(ENEMY_REWARDS.get(enemy_type, 0))
	if reward > 0:
		_add_gold(reward)

func _add_gold(amount: int) -> void:
	_gold += amount
	print("Oro: %d" % _gold)
	_update_gold_ui()

func _advance_wave() -> void:
	_current_wave += 1
	_current_wave_enemy_target = _calculate_next_wave_enemy_count(_current_wave_enemy_target, _current_wave)
	_prepare_wave()

func _calculate_next_wave_enemy_count(current_count: int, wave_number: int) -> int:
	var percent := _wave_increase_percent(wave_number)
	var scaled := int(ceil(float(current_count) * (1.0 + percent)))
	return max(scaled, enemies.size())

func _wave_increase_percent(wave_number: int) -> float:
	if wave_number <= 1:
		return 0.0
	if wave_number <= 5:
		return 0.05
	if wave_number <= 10:
		return 0.08
	return 0.10

func _build_spawn_queue(total_count: int) -> Array[StringName]:
	var enemy_keys: Array = enemies.keys()
	if enemy_keys.is_empty():
		return []

	_shuffle_array(enemy_keys)

	var queue: Array[StringName] = []
	for key in enemy_keys:
		queue.append(key)
		if queue.size() >= total_count:
			_shuffle_array(queue)
			return queue

	while queue.size() < total_count:
		var index := _rng.randi_range(0, enemy_keys.size() - 1)
		queue.append(enemy_keys[index])

	_shuffle_array(queue)
	return queue

func _shuffle_array(array: Array) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var temp = array[i]
		array[i] = array[j]
		array[j] = temp

func _update_wave_ui() -> void:
	if _wave_label:
		_wave_label.text = "Oleada %d" % _current_wave

	var remaining_to_spawn: int = max(0, _current_wave_enemy_target - _spawned_this_wave)
	var total_remaining: int = remaining_to_spawn + _enemies_alive
	if _enemies_label:
		_enemies_label.text = "Enemigos restantes: %d" % total_remaining
	_update_gold_ui()

func _update_gold_ui() -> void:
	if _gold_label:
		_gold_label.text = "Oro: %d" % _gold

func _get_label(node_path: String) -> Label:
	if has_node(node_path):
		var node := get_node(node_path)
		if node is Label:
			return node
	return null

func get_turret_cost(turret_name: StringName) -> int:
	return int(TURRET_COSTS.get(turret_name, 0))

func can_afford_turret(turret_name: StringName) -> bool:
	return _gold >= get_turret_cost(turret_name)

func try_purchase_turret(turret_name: StringName) -> bool:
	var cost := get_turret_cost(turret_name)
	if cost <= 0:
		return true
	if _gold < cost:
		print("Oro insuficiente para %s" % turret_name)
		return false
	_gold -= cost
	_update_gold_ui()
	print("Comprada torreta %s, oro restante: %d" % [turret_name, _gold])
	return true

extends Node2D
class_name Map_1

@export var enemy_spawn_number : float 
# Enemies
var enemies = {
	goblin = preload("res://Scenes/Enemies/goblin.tscn"),
	bat = preload("res://Scenes/Enemies/bat.tscn"),
	golem = preload("res://Scenes/Enemies/golem.tscn")
}

# Variables
var timer : Timer
var count : int = 0
var _turret_spawner: TurretSpawner

func _ready() -> void:
	# Crear el Timer
	timer = Timer.new()
	timer.wait_time = 1.2  # Tiempo entre spawns
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)

	# Conectar la señal timeout
	timer.timeout.connect(_on_timer_timeout)

	_turret_spawner = $TurretSpawner
	_setup_turret_buttons()

func _on_timer_timeout() -> void:
	if count < enemy_spawn_number:
		var keys = enemies.keys()
		var random_key = keys[randi() % keys.size()]
		var enemy_instance : Character = enemies[random_key].instantiate()
		enemy_instance.init_path($MapGeneration.get_path_node())
		
		get_tree().root.add_child(enemy_instance)


		enemy_instance.path = $MapGeneration.get_path_node()
		count += 1
	else: 
		
		print("Oleada terminada")
		timer.queue_free()


func _setup_turret_buttons() -> void:
	if not has_node("UI/Control/Panel/Buttons"):
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

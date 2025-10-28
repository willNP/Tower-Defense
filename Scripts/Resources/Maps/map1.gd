extends Path2D
class_name Map_1



# Enemies
var enemies = {
	goblin = preload("res://Scenes/Enemies/goblin.tscn"),
	bat = preload("res://Scenes/Enemies/bat.tscn")
}

# Variables
var timer : Timer
var count : int = 0

func _ready() -> void:
	# Crear el Timer
	timer = Timer.new()
	timer.wait_time = 1.2  # Tiempo entre spawns
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)

	# Conectar la señal timeout
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	if count < 20:
		var keys = enemies.keys()
		var random_key = keys[randi() % keys.size()]
		var enemy_instance : Character = enemies[random_key].instantiate()

		var path_follow = PathFollow2D.new()
		path_follow.loop = false
		path_follow.rotates = false
		path_follow.add_child(enemy_instance)
		add_child(path_follow)

		enemy_instance.pathFollow = path_follow
		enemy_instance.path = self

		count += 1
	else: 
		print("Oleada terminada")
		timer.queue_free()

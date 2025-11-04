extends Node2D
class_name Ammo

@export var speed : float
@export var dmg : float
var target : Character

@export_group("Status Effect Probabilities")
@export var poison_prob : int
@export var fire_prob : int
@export var stun_prob : int
@export var slow_prob : int

var status_effects : Dictionary = {
	poison = preload("res://Scripts/Status Effects/poison_effect.tres")
}


func _physics_process(delta: float) -> void:
	if target:
		var direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
		global_position += direction * speed * delta
	else:
		self.queue_free()	

func attack(_target : Character) -> void:
	target = _target

func apply_status() -> void:
	if poison_prob > 0:
		var  poison_chance = randi() % poison_prob
		if poison_chance <= poison_prob:
			if not status_effects.poison.init:
				target.add_child(status_effects.poison.timer)
			status_effects.poison.notify_effect(target)
			print("Si aplica veneno, ", poison_chance)
		else:
			print("No aplica veneno, ", poison_chance)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() == target:
		print("fadlfafl")
		target.receive_dmg(dmg)
		apply_status()
		self.queue_free()

extends Node2D
class_name Ammo

@export var speed : float
@export var dmg : float
var target : Character

func _physics_process(delta: float) -> void:
	if target:
		var direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
		global_position += direction * speed * delta
	else:
		self.queue_free()	

func attack(_target : Character) -> void:
	target = _target

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() == target:
		self.queue_free()
		target.receive_dmg(dmg)

extends Ammo
class_name CannonBall

func _ready() -> void: 
	$Area2D.area_entered.connect(_on_area_2d_area_entered)

func get_ammo_sprite() -> Sprite2D:
	return $Sprite2D

extends Ammo
class_name CrossbowArrow

func _ready() -> void:
	$Area2D.area_entered.connect(_on_area_2d_area_entered)

extends StaticBody2D
class_name Interactif

static var mask := 0b10
var temp := 5.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask |= mask
	collision_layer |= mask

func colect():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

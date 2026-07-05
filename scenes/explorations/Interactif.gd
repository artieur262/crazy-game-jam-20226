extends StaticBody2D
class_name Interactif

enum LOOTS {
	NONE,
	ARBRE,
	CHANVRE
}

## Définit le loot donné par cet objet.
@export var loot := LOOTS.ARBRE
@export var unspawn_on_collect := false
static var mask := 0b10
@export var temp := 5.0
var donne: Dictionary[Item, int] = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask |= mask
	collision_layer |= mask
	match loot:
		LOOTS.ARBRE:
			donne = {Items.bois: 5}
		LOOTS.CHANVRE:
			donne = {Items.chanvre: 3}


func collect() -> Dictionary[Item, int]:
	if unspawn_on_collect:
		queue_free()
	return donne

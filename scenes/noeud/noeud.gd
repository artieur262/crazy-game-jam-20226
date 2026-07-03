extends Node2D


@export var id : int = 0
var voisins : Array = []

func ajouter_voisin(n):
	if n == self:
		return
	if n in voisins:
		return
		
	voisins.append(n)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

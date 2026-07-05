extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func random_placement():
	for obj:Node2D in $spawnable.get_children():
		
		

func random_spaner(liste_parcouru:Variant, noeu:Node2D):
	var ran = randi_range(0)
		

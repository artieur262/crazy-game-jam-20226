extends TileMapLayer

var rayon_de_decouverte:int = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	decouvrir_autour(Vector2(200,200))
	




func decouvrir_autour(pos_p:Vector2):
	var position_grill := local_to_map(to_local(pos_p))
	for i in range(-rayon_de_decouverte+1, rayon_de_decouverte):
		for j in range(-rayon_de_decouverte+1,rayon_de_decouverte):
			var cat = Vector2i(position_grill.x+i, position_grill.y+j)
			erase_cell(cat)
	

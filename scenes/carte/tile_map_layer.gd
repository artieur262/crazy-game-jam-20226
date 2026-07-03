extends TileMapLayer

var rayon_de_decouverte:int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in range(3):
		for j in range(3):
			erase_cell(Vector2i(-1+i,-5+j))
	


func decouvrir_autour(pos_p:Vector2):
	var position_grill := map_to_local(pos_p)
	for i in range(rayon_de_decouverte):
		for j in range(rayon_de_decouverte):
			erase_cell(Vector2i(position_grill.x+i, position_grill.y+j))
	

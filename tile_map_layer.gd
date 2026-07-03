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
	

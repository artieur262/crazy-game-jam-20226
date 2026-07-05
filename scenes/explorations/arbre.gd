extends Interactif

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var arbre: Interactif = $"."

var is_inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_inside:
		sprite_2d.texture = preload("res://assets/exploration/changing/arbre_selected.png")
	else:
		sprite_2d.texture = preload("res://assets/exploration/changing/arbre.png")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if(body != arbre):
		is_inside = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if(body != arbre):
		is_inside = false

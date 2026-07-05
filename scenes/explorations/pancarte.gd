extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var label: Label = $Label

var is_inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("interact") and is_inside):
		print("retour au chariot")
		Jeu.retour_chariot()

func _on_area_2d_body_entered(body: Node2D) -> void:
	label.visible = true
	is_inside = true
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	label.visible = false
	is_inside = false

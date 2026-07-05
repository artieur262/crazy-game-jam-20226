extends StaticBody2D

@onready var label: Label = $Label
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pancarte: StaticBody2D = $"."

var is_inside = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.visible = false
	sprite_2d.texture = preload("res://assets/exploration/changing/Pancarte.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("interact") and is_inside):
		print("retour au chariot")
		Jeu.retour_chariot()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != pancarte:
		sprite_2d.texture = preload("res://assets/exploration/changing/pancarte_selected.png")
		label.visible = true
		is_inside = true
	

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != pancarte:
		sprite_2d.texture = preload("res://assets/exploration/changing/Pancarte.png")
		label.visible = false
		is_inside = false

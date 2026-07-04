extends VSplitContainer


func _ready() -> void:
	# Corrige la position du Node2D (qui bouge au lancement pour une raison inconue)
	$MapSubViewportContainer/MapSubViewport/Map.position = Vector2.ZERO


func _on_direction_pressed() -> void:
	pass


func _on_reparer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/reparations/reparations.tscn")


func _on_explorer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/explorations/explorations.tscn")


func _on_preparer_un_camp_pressed() -> void:
	pass

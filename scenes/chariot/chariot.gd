extends VSplitContainer

func _ready() -> void:
	# Corrige la position du Node2D (qui bouge au lancement pour une raison inconue)
	$MapSubViewportContainer/MapSubViewport/TileMapLayer.position = Vector2.ZERO
	get_window().size_changed.connect(corriger_map)
	drag_ended.connect(corriger_map)
	call_deferred("corriger_map")


func corriger_map():
	# Permet à la camera de réinitialiser ses variables internes.
	$MapSubViewportContainer/MapSubViewport/TileMapLayer/Camera2D.modifier_zoom(0.1)
	$MapSubViewportContainer/MapSubViewport/TileMapLayer/Camera2D.modifier_zoom(-0.1)


## Appellé quand le bouton "choisir une direction" est appuyé.
func _on_direction_pressed() -> void:
	pass


## Appellé quand le bouton "réparer le chariot" est appuyé.
func _on_reparer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/reparations/reparations.tscn")


## Appellé quand le bouton "explorer" est appuyé.
func _on_explorer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/explorations/explorations.tscn")


## Appellé quand le bouton "préparer le camp" est appuyé.
func _on_preparer_un_camp_pressed() -> void:
	pass

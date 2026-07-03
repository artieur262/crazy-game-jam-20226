extends VSplitContainer


func _ready() -> void:
	# Corrige la position du Node2D (qui bouge au lancement pour une raison inconue)
	$MapSubViewportContainer/MapSubViewport/Map.position = Vector2.ZERO


func _on_direction_pressed() -> void:
	pass


func _on_reparer_pressed() -> void:
	pass


func _on_explorer_pressed() -> void:
	pass


func _on_préparer_un_camp_pressed() -> void:
	pass

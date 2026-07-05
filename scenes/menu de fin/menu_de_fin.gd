extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func hide_all():
	$ConfirmationQuiter.hide()


func _on_retou_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu principal/menu principal.tscn")

func afficher(text: String):
	$Popup.title = text
	$Popup.show()

func _on_crédits_pressed() -> void:
	hide_all()

func _on_quiter_pressed() -> void:
	hide_all()
	$ConfirmationQuiter.visible = true

func _on_confirmation_quiter_confirmed() -> void:
	get_tree().quit(0)

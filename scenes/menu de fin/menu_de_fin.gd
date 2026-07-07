extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func hide_all():
	$ConfirmationQuiter.hide()


func _on_retour_au_menu_principal_pressed() -> void:
	charger_menu_principal(false)

func _on_crédits_pressed() -> void:
	charger_menu_principal(true)

## Charge la scene du menu principal.
func charger_menu_principal(credits := false) -> void:
	var scene := preload("res://scenes/menu principal/menu principal.tscn")
	var noeud := scene.instantiate()
	if credits:
		noeud._on_credits_pressed()
	get_tree().change_scene_to_node(noeud)

func _on_quiter_pressed() -> void:
	hide_all()
	$ConfirmationQuiter.visible = true

func _on_confirmation_quiter_confirmed() -> void:
	get_tree().quit(0)

extends CenterContainer

var sauvegardes: Array = []

## Liste les sauvagerdes.
func lister_sauvegardes() -> Array:
	var noms := []
	for nom in DirAccess.get_files_at("res://saves"):
		if nom.ends_with(".json"):
			noms.append(nom)
	return noms

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sauvegardes = Jeu.lister_sauvegardes()
	if sauvegardes.size() == 0:
		$HBoxContainer/Charger.disabled = true


func _on_jouer_pressed() -> void:
	$NomSauvagarde/VBoxContainer/Nom.text = ""
	$NomSauvagarde.show()

func _on_valider_nom_pressed() -> void:
	var nom = $NomSauvagarde/VBoxContainer/Nom.text
	if nom == "":
		return
	Jeu.nom = nom
	var carte_scene := preload("res://scenes/carte/Carte.tscn")
	Jeu.carte = carte_scene.instantiate()
	Jeu.carte.config()
	Generateur.genere_routes(Jeu.carte)
	Jeu.position_joueur = Jeu.checkpoint_depart.position
	Jeu.carte.reset_brouillard()
	Jeu.position_joueur = Jeu.checkpoint_depart.position
	get_tree().change_scene_to_file("res://scenes/chariot/chariot.tscn")

func _on_charger_pressed() -> void:
	pass # Replace with function body.


func _on_paramètres_pressed() -> void:
	pass # Replace with function body.



func _on_crédits_pressed() -> void:
	pass # Replace with function body.



func _on_quiter_pressed() -> void:
	$ConfirmationQuiter.visible = true

func _on_confirmation_quiter_confirmed() -> void:
	get_tree().quit(0)

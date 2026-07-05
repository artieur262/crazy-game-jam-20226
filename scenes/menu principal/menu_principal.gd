extends CenterContainer

var sauvegardes: Array = []
var sauvegardes_listes := false
var delete_info: Array

## Liste les sauvagerdes.
func lister_sauvegardes() -> Array:
	var noms := []
	for nom in DirAccess.get_files_at("user://saves"):
		if nom.ends_with(".json"):
			noms.append("user://saves/%s" % nom)
	return noms

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sauvegardes = lister_sauvegardes()
	if sauvegardes.size() == 0:
		$HBoxContainer/Charger.disabled = true

func hide_all():
	$ConfirmationQuiter.hide()
	$ConfirmationSupprimer.hide()
	$NomSauvagarde.hide()
	$Sauvegardes.hide()


func _on_jouer_pressed() -> void:
	hide_all()
	$NomSauvagarde/VBoxContainer/Nom.text = ""
	$NomSauvagarde.show()

func _on_valider_nom_pressed() -> void:
	var nom = $NomSauvagarde/VBoxContainer/Nom.text
	if nom == "":
		return
	Jeu.nouvelle_partie()
	Jeu.nom = nom
	var carte_scene := preload("res://scenes/carte/Carte.tscn")
	Jeu.carte = carte_scene.instantiate()
	Jeu.carte.config()
	Generateur.genere_routes(Jeu.carte)
	Jeu.position_joueur = Jeu.checkpoint_depart.position
	Jeu.carte.reset_brouillard()
	get_tree().change_scene_to_file("res://scenes/chariot/chariot.tscn")

func lire(sauvegarde: String):
	var file = FileAccess.open(sauvegarde, FileAccess.READ)
	if file == null:
		return file
	var donnees = JSON.parse_string(file.get_as_text())
	file.close()
	return donnees

func _on_charger_pressed() -> void:
	hide_all()
	if sauvegardes_listes:
		if len($Sauvegardes/Bouttons/Parties.get_children()) == 0:
			afficher("Aucune sauvegarde trouvée.")
			$HBoxContainer/Charger.disabled = true
			return
		$Sauvegardes.show()
		return
	sauvegardes_listes = true
	var trouve := false
	for sauvegarde in sauvegardes:
		var donnees = lire(sauvegarde)
		if donnees == null:
			continue
		var id = donnees.get("id")
		if id == null:
			continue
		if id is float:
			id = int(id)
		if id is not int:
			continue
		var nom = donnees.get("nom")
		if nom == null:
			continue
		if nom is not String:
			continue
		var boutton := Button.new()
		boutton.text = nom
		var supprimer := Button.new()
		supprimer.text = "supprimer"
		var bouttons: Array[Button] = [boutton, supprimer]
		boutton.pressed.connect(func(): charger(id, bouttons))
		$Sauvegardes/Bouttons/Parties.add_child(boutton)
		supprimer.pressed.connect(func(): supprimer(id, bouttons))
		$Sauvegardes/Bouttons/Supprimer.add_child(supprimer)
		trouve = true
	if not trouve:
		afficher("Aucune sauvegarde lisible trouvée.")
		$HBoxContainer/Charger.disabled = true
		return
	$Sauvegardes.show()

func charger(id: int, boutton: Array[Button]):
	var donnees = lire("user://saves/%s.json" % id)
	if donnees == null:
		return sauvegarde_illisible(boutton)
	Jeu.nouvelle_partie()
	Jeu.id = id
	var nom = donnees.get("nom")
	if nom == null:
		return sauvegarde_illisible(boutton)
	if nom is not String:
		return sauvegarde_illisible(boutton)
	Jeu.nom = nom
	var camp_pret = donnees.get("camp_pret")
	if camp_pret == null:
		return sauvegarde_illisible(boutton)
	if camp_pret is not bool:
		return sauvegarde_illisible(boutton)
	var jour = donnees.get("jour")
	if jour == null:
		return sauvegarde_illisible(boutton)
	if jour is float:
		jour = int(jour)
	elif jour is not int:
		return sauvegarde_illisible(boutton)
	var phase_actuelle = donnees.get("phase_actuelle")
	if phase_actuelle == null:
		return sauvegarde_illisible(boutton)
	elif phase_actuelle is float:
		phase_actuelle = int(jour)
	if phase_actuelle is not int:
		return sauvegarde_illisible(boutton)
	var salete = donnees.get("salete")
	if salete == null:
		return sauvegarde_illisible(boutton)
	if salete is float:
		salete = int(jour)
	elif salete is not int:
		return sauvegarde_illisible(boutton)
	var position_joueur = donnees.get("position_joueur")
	if position_joueur is not Array:
		return sauvegarde_illisible(boutton)
	if position_joueur.size() != 2:
		return sauvegarde_illisible(boutton)
	var pos = Vector2()
	if position_joueur[0] is float:
		pos.x = int(position_joueur[0])
	elif position_joueur[0] is int:
		pos.x = position_joueur[0]
	else:
		return sauvegarde_illisible(boutton)
	if position_joueur[1] is float:
		pos.y = int(position_joueur[1])
	elif position_joueur[1] is int:
		pos.y = position_joueur[1]
	else:
		return sauvegarde_illisible(boutton)
	Jeu.camp_pret = camp_pret
	Jeu.jour = jour
	Jeu.phase_actuelle = phase_actuelle
	Jeu.salete = salete
	if not Jeu.inventaire.import(donnees.get("inventaire")):
		return sauvegarde_illisible(boutton)
	Jeu.dommages = Dommage.imports(donnees.get("dommages"))
	if Dommage.got_error:
		return sauvegarde_illisible(boutton)
	var carte_scene = preload("res://scenes/carte/CarteVide.tscn")
	var carte := carte_scene.instantiate()
	Jeu.carte = carte
	carte.reset_brouillard()
	Jeu.position_joueur = pos
	if not carte.import(donnees.get("carte")):
		return sauvegarde_illisible(boutton)
	carte.config()
	Jeu.position_joueur = pos
	Generateur.dessiner_routes(
		carte, Jeu.checkpoint_depart, [])
	get_tree().change_scene_to_file("res://scenes/chariot/chariot.tscn")

func supprimer(id: int, bouttons: Array[Button]):
	hide_all()
	delete_info = [id, bouttons]
	$ConfirmationSupprimer.show()

func _on_confirmation_supprimer_confirmed() -> void:
	for boutton in delete_info[1]:
		boutton.queue_free()
	DirAccess.remove_absolute("user://saves/%s.json" % delete_info[0])

func sauvegarde_illisible(bouttons: Array[Button]):
	afficher("Cette sauvegarde n'est pas lisible.")
	for boutton in bouttons:
		boutton.queue_free()

func afficher(text: String):
	$Popup.title = text
	$Popup.show()


func _on_paramètres_pressed() -> void:
	hide_all()
	pass # Replace with function body.

func _on_crédits_pressed() -> void:
	hide_all()

func _on_quiter_pressed() -> void:
	hide_all()
	$ConfirmationQuiter.visible = true

func _on_confirmation_quiter_confirmed() -> void:
	get_tree().quit(0)

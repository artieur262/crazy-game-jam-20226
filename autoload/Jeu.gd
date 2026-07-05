## Singleton contenant l'état du jeu.
extends Node

## Liste des phases possibles pour le jeu.
enum PHASES {
	## Prépartie, avant que l'utilisateur puisse interragir un tuto/résumé ou autre.
	## Suite: [constant PREMIERE_SELECTION].
	PREPARTIE,
	## Résumé de ce qu'il s'est passé durant la nuit.
	## Suite: [constant PREMIERE_SELECTION].
	RESUME,
	## Première phase de selection d'une action.
	## Suite: [constant PHASE_UN].
	PREMIERE_SELECTION,
	## Phase d'action un.
	## Suite: [constant SECONDE_SELECTION].
	PHASE_UN,
	## Deuxieme phase de selection d'une action.
	## Suite: [constant PHASE_DEUX].
	SECONDE_SELECTION,
	## Phase d'action deux.
	## Suite: [constant NUIT].
	PHASE_DEUX,
	## Phase de nuit.
	## Suite: [constant RESUME]
	NUIT
}

## Signal émit quand un nouveau jour début.
## Début sur [constant PHASES.RESUME] après que resultat_nuit soit rempli.
signal nouveau_jour
## Signal émit quand le joueur change de position/[Checkpoint].
## Le premier arg est la destination le second est l'origine.
signal joueur_change_de_position(dest: Vector2, origine: Vector2)
## Position du joueur sur la [member carte].
var position_joueur: Vector2:
	set(pos):
		var ancienne_pos := position_joueur
		position_joueur = pos
		joueur_change_de_position.emit(position_joueur, ancienne_pos)
## [Checkpoint] de départ.
var checkpoint_depart: Checkpoint
## [Checkpoint] d'arrivée.
var checkpoint_arrive: Checkpoint
## [Carte] utilisée sur cette partie.
var carte: Carte
## Id de la partie.
var id: int
## Nom de la partie.
var nom: String
## [Dommage]s du chariot.
var dommages: Array[Dommage]
## [Inventaire] du joueur.
var inventaire: Inventaire
## Phase actuelle du jeu.
var phase_actuelle: PHASES
## Flag qui indique si le camp est installé.
var camp_pret: bool
## Nombre de jours écoulés.
var jour: int
## [GameEvent] qui se sont passé durant la nuit.
var resultat_nuit: Array[GameEvent]
## Saletée produite par le cheval peux causer [member EventsDommages.salete] et cause
## des dégradation à un certain seuil.
var salete: int
##
var charette_immobilise := false

## Prépare une nouvelle partie.
func nouvelle_partie():
	id = (randi() << 32&0x00FFFFFF) | randi()
	inventaire = Inventaire.new()
	phase_actuelle = PHASES.PREPARTIE
	camp_pret = true
	jour = 0
	salete = 0

## Sauvegarde la partie.
func sauvegarder():
	var donnees := {
		"id": id,
		"nom": nom,
		"carte": carte.export(),
		"dommages": Dommage.exports(dommages),
		"inventaire": inventaire.export(),
		"jour": jour,
		"camp_pret": camp_pret,
		"phase_actuelle": phase_actuelle,
		"salete": 0,
		"position_joueur": [
			position_joueur.x,
			position_joueur.y
		],
	}
	if not DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_recursive_absolute("user://saves")
	var file := FileAccess.open(
		"user://saves/%d.json" % id, FileAccess.WRITE)
	file.store_string(JSON.stringify(donnees))
	file.close()

## Ramène le joueur à la scene du chariot.
func retour_chariot():
	get_tree().change_scene_to_file("res://scenes/chariot/chariot.tscn")
	prochaine_phase()

## Prépare le camp.
## Retourne un [bool] indiquant si le camp a été construit ou
## si il était déjà en place.
func preparer_camp() -> bool:
	if camp_pret:
		return false
	camp_pret = true
	return true

## Code executant les malus de nuit.
func nuit():
	resultat_nuit = EventsDommages.applique()
	salete += randi_range(0, 10)
	if randi_range(0, dommages.count(EventsDommages.salete)*3):
		resultat_nuit.append(GameEvent.new(
			"Saleté",
			"La saleté qui s'est accumulée sur la chariot l'a dégradé.",
			[EventsDommages.habitacle], false))
	if salete > 40:
		resultat_nuit.append(GameEvent.new(
			"Saleté",
			"À force de laisser le cheval en liberté il nous salis la charrette.",
			[EventsDommages.salete], false))
		salete -= 40
	calcul_degats()
	prochaine_phase()

## Prépare la partie.
func preparer_jeu():
	if phase_actuelle == PHASES.PREPARTIE:
		prochaine_phase()

## Passe à la prochaine phase de jeu et la retourne.
func prochaine_phase() -> PHASES:
	match phase_actuelle:
		PHASES.PREPARTIE:
			phase_actuelle = PHASES.PREMIERE_SELECTION
		PHASES.RESUME:
			nouveau_jour.emit()
			jour += 1
			phase_actuelle = PHASES.PREMIERE_SELECTION
		PHASES.PREMIERE_SELECTION:
			phase_actuelle = PHASES.PHASE_UN
		PHASES.PHASE_UN:
			phase_actuelle = PHASES.SECONDE_SELECTION
		PHASES.SECONDE_SELECTION:
			phase_actuelle = PHASES.PHASE_DEUX
		PHASES.PHASE_DEUX:
			phase_actuelle = PHASES.NUIT
			nuit()
		_:
			phase_actuelle = PHASES.RESUME
	return phase_actuelle

## Retourne à la phase précédente de jeu et la retourne.
func retour_phase() -> PHASES:
	match phase_actuelle:
		PHASES.PREMIERE_SELECTION:
			phase_actuelle = PHASES.RESUME
		PHASES.PHASE_UN:
			phase_actuelle = PHASES.PREMIERE_SELECTION
		PHASES.SECONDE_SELECTION:
			phase_actuelle = PHASES.PHASE_UN
		PHASES.PHASE_DEUX:
			phase_actuelle = PHASES.SECONDE_SELECTION
	return phase_actuelle
	
	
func fin():
	get_tree().change_scene_to_file("res://scenes/menu de fin/menu de fin.tscn")

func calcul_degats():
	var solde_immobilisation := 20
	var solde_casse := 60
	for dommage in dommages:
		if dommage == EventsDommages.roue_perdue:
			solde_immobilisation -= 25
			solde_casse -= 3
		elif dommage == EventsDommages.habitacle:
			solde_immobilisation -= 3
			solde_casse -= 25
		elif dommage == EventsDommages.rideau_habimes:
			solde_immobilisation -= 0
			solde_casse -= 2
	charette_immobilise = solde_immobilisation < 0
	if solde_casse < 0:
		if randi_range(0, abs(solde_casse)):
			perdu("Votre charette a pris trop de dégâts.")

func perdu(message):
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var vbox := VBoxContainer.new()
	var label := Label.new()
	var boutton := Button.new()
	vbox.add_child(label)
	vbox.add_child(boutton)
	label.text = message
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boutton.text = "Quiter"
	boutton.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boutton.pressed.connect(fin)
	var freee := func ():
		vbox.queue_free()
		boutton.queue_free()
		label.queue_free()
		center.queue_free()
	boutton.pressed.connect(freee)
	center.add_child(vbox)
	
	for child in get_tree().root.get_children():
		if child is Node2D:
			pass
		elif child is Control:
			pass
		elif child is Node3D:
			pass
		else:
			continue
		child.visible = false
	get_tree().root.add_child(center)

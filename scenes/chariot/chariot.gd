extends VSplitContainer

var carte: Carte
var en_deplacement := false


## Initialise la scene avec la [Carte] fournie.
func _ready() -> void:
	if carte == null:
		carte = Jeu.carte
	carte.checkpoint_selectionne.connect(_on_clic_checkpoint)
	$MapSubViewportContainer/MapSubViewport.add_child(carte)
	# Corrige la position du Node2D (qui bouge au lancement pour une raison inconue)
	carte.position = Vector2.ZERO
	get_window().size_changed.connect(corriger_map)
	drag_ended.connect(corriger_map)
	call_deferred("corriger_map")
	var bouton: Button = $ConfirmationQuiter.add_button("Sauvegarder")
	bouton.pressed.connect(self.sauvegarder)
	carte.checkpointViaPos(Jeu.position_joueur).joueur_dessus(true)
	Jeu.preparer_jeu()

## Corrige la [Carte] après une transformation du viewport
## (ou de la fenêtre) pour remettre la [Carte] en place.
func corriger_map():
	# Permet à la camera de réinitialiser ses variables internes.
	carte.camera.modifier_zoom(0.1)
	carte.camera.modifier_zoom(-0.1)

## Tente de passer vers une phase principale (PHASE_UN, PHASE_DEUX)
## Retourne false si ce n'est pas possible.
func passer_en_phase_principale(auto_warning := false) -> bool:
	if Jeu.phase_actuelle == Jeu.PHASES.RESUME:
		Jeu.prochaine_phase()
	if Jeu.phase_actuelle == Jeu.PHASES.PREMIERE_SELECTION:
		Jeu.prochaine_phase()
		return true
	elif Jeu.phase_actuelle == Jeu.PHASES.SECONDE_SELECTION:
		Jeu.prochaine_phase()
		return true
	if auto_warning:
		afficher_info("Demande invalide pour ce stade du jeu.")
	return false

## Affiche un texte à l'utilisateur.
func afficher_info(text: String):
	$EcranBas/Interface/Console.text += text + "\n"

# ----------------- Déplacements -----------------
## Connecté à [signal Carte.checkpoint_selectionne] et indique
## si le joeur a cliqué sur un checkpoint et déplace le joueur
## si possible et si le déplacement est en cours.
func _on_clic_checkpoint(checkpoint: Checkpoint):
	if en_deplacement:
		if not passer_en_phase_principale(true):
			$EcranBas/Interface/bouttons/Boutons/Direction.\
				button_pressed = true
			$EcranBas/Interface/bouttons/Boutons/Direction.\
				button_pressed = false
			return
		var checkpoint_joueur = carte.checkpointViaPos(
			Jeu.position_joueur)
		if checkpoint_joueur == checkpoint:
			afficher_info(
				"Vous ne pouvez pas vous déplacer là où vous êts déjà.")
			return
		if est_visitable(checkpoint_joueur, checkpoint, [], 0):
			return
		afficher_info(
			"Ce checkpoint est trop loin pour être atteignable.")

## Cherche si il est possible d'aller sur le noeud de
## destination et déplace le joueur le cas échant.
func est_visitable(
		depart: Checkpoint,
		destination: Checkpoint,
		checkpoints_visitables: Array[Checkpoint] = [],
		nombre_de_saut := 0) -> bool:
	for checkpoint_visitable in depart.liste_connection():
		if checkpoint_visitable == destination:
			aller_sur(destination)
			return true
		checkpoints_visitables.append(checkpoint_visitable)
		if not checkpoint_visitable.visite or nombre_de_saut > 0:
			continue
		if est_visitable(
				checkpoint_visitable,
				destination,
				checkpoints_visitables,
				nombre_de_saut + 1):
			return true
	return false

## Déplace le joueur vers le checkpoint indiqué.
func aller_sur(checkpoint: Checkpoint):
	carte.checkpointViaPos(Jeu.position_joueur).joueur_dessus(false)
	Jeu.position_joueur = checkpoint.position
	checkpoint.joueur_dessus(true)
	checkpoint.visite = true
	Jeu.camp_pret = false
	Jeu.prochaine_phase()

## Appelé quand le bouton "Choisir une direction" est appuyé ou relaché.
func _on_direction_toggled(toggled_on: bool) -> void:
	en_deplacement = toggled_on

# ----------------- boutons de scene -----------------

## Appellé quand le bouton "réparer le chariot" est appuyé.
func _on_reparer_pressed() -> void:
	if not passer_en_phase_principale(true):
		return
	Jeu.sauvegarder()
	get_tree().change_scene_to_file("res://scenes/reparations/reparations.tscn")


## Appellé quand le bouton "explorer" est appuyé.
func _on_explorer_pressed() -> void:
	if not passer_en_phase_principale(true):
		return
	Jeu.sauvegarder()
	get_tree().change_scene_to_file("res://scenes/explorations/explorations.tscn")


## Appellé quand le bouton "préparer le camp" est appuyé.
func _on_preparer_un_camp_pressed() -> void:
	if passer_en_phase_principale(true):
		var result := Jeu.preparer_camp()
		if result == false:
			afficher_info("Le camp est déjà prêt.")
			Jeu.retour_phase()
			return
		Jeu.prochaine_phase()

# ----------------- Quitter -----------------

## Appellé quand le boutton "Quiter" est appuyé.
func _on_quiter_pressed() -> void:
	$ConfirmationQuiter.show()

## Appellé quand le joueur a confirmé de quiter.
func _on_confirmation_quiter_confirmed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu principal/menu principal.tscn")

## Appellé quand le joueur a demandé de sauvegarder.
func sauvegarder() -> void:
	Jeu.sauvegarder()
	_on_confirmation_quiter_confirmed()

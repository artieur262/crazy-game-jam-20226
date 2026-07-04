extends VSplitContainer

var carte: Carte
var en_deplacement := false


## Initialise la scene avec la [Carte] fournie.
func init(arg_carte: Carte):
	carte = arg_carte
	carte.checkpoint_selectionne.connect(_on_clic_checkpoint)
	$MapSubViewportContainer/MapSubViewport.add_child(carte)


func _enter_tree() -> void:
	# Corrige la position du Node2D (qui bouge au lancement pour une raison inconue)
	carte.position = Vector2.ZERO
	get_window().size_changed.connect(corriger_map)
	drag_ended.connect(corriger_map)
	call_deferred("corriger_map")
	var bouton: Button = $ConfirmationQuiter.add_button("Sauvegarder")
	bouton.pressed.connect(self.sauvegarder)
	carte.checkpointViaPos(Jeu.position_joueur).joueur_dessus(false)

## Corrige la [Carte] après une transformation du viewport
## (ou de la fenêtre) pour remettre la [Carte] en place.
func corriger_map():
	# Permet à la camera de réinitialiser ses variables internes.
	carte.camera.modifier_zoom(0.1)
	carte.camera.modifier_zoom(-0.1)

# ----------------- Déplacements -----------------
## Connecté à [signal Carte.checkpoint_selectionne] et indique
## si le joeur a cliqué sur un checkpoint et déplace le joueur
## si possible et si le déplacement est en cours.
func _on_clic_checkpoint(checkpoint: Checkpoint):
	if en_deplacement:
		var checkpoint_joueur = carte.checkpointViaPos(
			Jeu.position_joueur)
		if est_visitable(checkpoint_joueur, checkpoint, [], 0):
			return
		$EcranBas/Interface/Warnings.text += (
			"Ce checkpoint est trop loin pour être atteignable.\n")

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

## Appelé quand le bouton "Choisir une direction" est appuyé ou relaché.
func _on_direction_toggled(toggled_on: bool) -> void:
	en_deplacement = toggled_on

# ----------------- boutons de scene -----------------

## Appellé quand le bouton "réparer le chariot" est appuyé.
func _on_reparer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/reparations/reparations.tscn")


## Appellé quand le bouton "explorer" est appuyé.
func _on_explorer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/explorations/explorations.tscn")


## Appellé quand le bouton "préparer le camp" est appuyé.
func _on_preparer_un_camp_pressed() -> void:
	pass

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

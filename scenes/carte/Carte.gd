## UI de la carte du monde.
extends TileMapLayer
class_name Carte

## Signal emit par les checkpoint lorsqu'un d'entre eux est cliqué.
## Voir [signal Checkpoint.selectionne]
signal checkpoint_selectionne(Checkpoint)

## Rayon (en nombre de case) autour du personnages qui seront dévoillé lors des déplacements.
@export var rayon_de_decouverte := 2
## Distance max (en pixels) entre deux [Checkpoint]
@export var distance_max := 500

## Liste des [Checkpoints] de cette [Carte].
@export var checkpoints: Array[Checkpoint] = []

## Taile de la [Carte] en nombre de case.
@export var taille_carte := Vector2i(100, 75)
## [Checkpoint] de départ de la [Carte].
@export var depart: Checkpoint
## [Checkpoint] d'arrivée de la [Carte].
@export var arrive: Checkpoint

## [Camera2D] utilisée sur cette map.
@onready var camera := $Camera2D

## Flag déterminant si un drag and drop est en cours.
var dragging := false

## Configure le jeu avec les [Checkpoint] de départ et
## d'arrivée définit sur cette map.
func config():
	Jeu.checkpoint_depart = depart
	Jeu.checkpoint_arrive = arrive

## Exporte les données en un dictionnaire pour être sauvergardées.
## Sauvegarde la [Carte], les [Checkpoint]s et les routes.
func export() -> Dictionary:
	return {
		"map": _export_map(),
		"checkpoint": _export_checkpoint(),
		"routes": _export_routes()
	}

func _export_map():
	var tuiles_decouvertes: Array[Array]
	for x in range(taille_carte.x):
		for y in range(taille_carte.y):
			if get_cell_source_id(Vector2i(x, y)) == null:
				tuiles_decouvertes.append([x, y])
	return tuiles_decouvertes

func _export_checkpoint() -> Array:
	var prepare: Array = []
	for checkpoint in checkpoints:
		prepare.append({
			"pos": checkpoint.position
		})


## Reset le brouillard en mettant du brouillard sur toutes
## les tuiles.
func reset_brouillard() -> void:
	Jeu.joueur_change_de_position.connect(_on_joueur_change_de_position)
	for x in range(taille_carte.x):
		for y in range(taille_carte.y):
			set_cell(Vector2i(x, y), 0, Vector2i(0,0), 0)


## Reposition les [Checkpoint] pour qu'il soit centré sur les tuile.
func reposition_checkpoints():
	for checkpoint in checkpoints:
		checkpoint.position = map_to_local(
			local_to_map(checkpoint.position))

## Returne le [Checkpoint] qui est sur cette tuile.
## [null] si introuvable.
func checkpointViaTuile(pos: Vector2i) -> Checkpoint:
	for checkpoint in checkpoints:
		if local_to_map(checkpoint.position) == pos:
			return checkpoint
	return null

## Returne le [Checkpoint] qui est sur la tuile au coordonées donnée..
## [null] si introuvable.
func checkpointViaPos(pos: Vector2) -> Checkpoint:
	return checkpointViaTuile(local_to_map(pos))



## Connecté à [signal Jeu.position_joueur] pour mettre à jour la
## [Carte] en fonction des déplacements du joueur.
func _on_joueur_change_de_position(
		dest: Vector2, origine: Vector2) -> void:
	var tuile_origine := local_to_map(origine)
	var tuile_dest := local_to_map(dest)
	var distance: Vector2i = tuile_dest-tuile_origine

	var nombre_iteration: float = max(abs(distance.x), abs(distance.y), 1)
	var i = 0
	var step_x = float(distance.x)/nombre_iteration
	var step_y = float(distance.y)/nombre_iteration
	var pos := Vector2(tuile_origine)
	while i < nombre_iteration:
		pos.x += step_x
		pos.y += step_y
		decouvrir_autour_de_case(Vector2i(pos))
		i += 1
	decouvrir_autour_de_case(tuile_dest)


## Prend des coordonées globales et dévoiles les cases avec pour rayon [member rayon_de_decouverte].
## Cette fonction nécessite des position globales pour convertir une position locale en globale
## voir [method Node2D.to_global]
func decouvrir_autour(pos_globale: Vector2):
	var position_grille := local_to_map(to_local(pos_globale))
	decouvrir_autour_de_case(position_grille)


## Prend des coordonées de la case et dévoiles les cases avec pour rayon
## [member rayon_de_decouverte].  Voir [method decouvrir_autour] pour
## utiliser des coordonées globales/locales au lieu d'une coordonée
## de tuile.
func decouvrir_autour_de_case(position_grille: Vector2i):
	for i in range(-rayon_de_decouverte+1, rayon_de_decouverte):
		for j in range(-rayon_de_decouverte+1,rayon_de_decouverte):
			erase_cell(Vector2i(position_grille.x+i, position_grille.y+j))


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action("drag"):
			dragging = event.is_pressed()
		elif event.is_action_pressed("zoom"):
			camera.modifier_zoom(0.3)
		elif event.is_action_pressed("dezoom"):
			camera.modifier_zoom(-0.3)
	if event is InputEventMouseMotion and dragging:
		camera.bouger(-event.relative)

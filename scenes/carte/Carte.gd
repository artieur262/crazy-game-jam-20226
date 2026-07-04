## UI de la carte du monde.
extends TileMapLayer
class_name Carte

## Signal emit par les checkpoint lorsqu'un d'entre eux est cliqué.
## Voir [signal Checkpoint.selectionne]
signal checkpoint_selectionne(Checkpoint)

## Rayon (en nombre de case) autour du personnages qui seront dévoillé lors des déplacements.
@export var rayon_de_decouverte := 4
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

## Reset le brouillard en mettant du brouillard sur toutes
## les tuiles.
func reset_brouillard() -> void:
	Jeu.joueur_change_de_position.connect(decouvrir_autour)
	for x in range(taille_carte.x):
		for y in range(taille_carte.y):
			set_cell(Vector2i(x, y), 1, Vector2i(0,0), 0)


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
## [Carte] en fonction de la position du joueur.
func _on_joueur_change_de_position(pos: Vector2) -> void:
	decouvrir_autour(Vector2(200,200))


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

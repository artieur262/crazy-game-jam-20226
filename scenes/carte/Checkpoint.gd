
## Classe représentant un checkpoint sur lequel un joueur peux se poser.
extends MeshInstance2D
class_name Checkpoint

## Émit quand ce checkpoint est selectionné.
## Pour écouter indépendamment du checkpoint voir [signal Map.checkpoint_selectionne]
signal selectionne

## [Carte] associé à ce checkpoint.
@onready var carte: Carte = get_parent()
## Liste des [Checkpoint] auquel celui-ci est connecté
@export var connections: Array
## Définir si le checkpoint a été visité par le joueur.
var visite := false

## Texture utilisé par le checkpoint quand le joueur est dessus.
const DESSUS := preload("res://assets/carte/checkpoint visite.png")
## Texture utilisé par le checkpoint quand le joueur n'est
## pas dessus.
const PAS_DESSUS := preload("res://assets/carte/checkpoint.png")


func _init():
	visite = false
	connections = []

## Appellé par le chariot pour faire changer la texture
## en fonction de si le joueur est dessus ou non.
func joueur_dessus(toogle: bool):
	texture = DESSUS if toogle else PAS_DESSUS

## Ajoute le [Checkpoint] donnée à la liste des connection si il n'est pas déjà connecté.
func connecte_checkpoint(checkpoint: Checkpoint) -> void:
	if self == checkpoint:
		return
	if not connections.has(checkpoint):
		connections.append(checkpoint)
		checkpoint.connections.append(self)

## Supprime le [Checkpoint] donnée de la liste de connections si il était connecté.
func deconnecte_checkpoint(checkpoint: Checkpoint) -> void:
	if connections.has(checkpoint):
		connections.erase(checkpoint)
		checkpoint.connections.erase(self)

## Retourne la liste des [Checkpoint] connectées à celui-ci.
func liste_connection() -> Array[Checkpoint]:
	return connections

## Return un [bool] indiquant si le checkpoint donnée est connecté.
func est_connecte(checkpoint: Checkpoint) -> bool:
	return connections.has(checkpoint)

func _input(event: InputEvent) -> void:
	if event.is_action("selectionner"):
		var mouse_pos := get_local_mouse_position()
		var rayon: Vector2 = Vector2.ONE * (5/carte.camera.zoom.x)
		if (
				mouse_pos.x > -rayon.x and
				mouse_pos.y > -rayon.y and
				mouse_pos.x < rayon.x and
				mouse_pos.y < rayon.y):
			carte.checkpoint_selectionne.emit(self)
			selectionne.emit(self)
			get_viewport().set_input_as_handled()
		pass

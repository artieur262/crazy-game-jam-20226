
## Classe représentant un checkpoint sur lequel un joueur peux se poser.
extends Node2D
class_name Checkpoint

## Liste des [Checkpoint] auquel celui-ci est connecté
@export var connections: Array[Checkpoint]

func _init(position: Vector2):
	self.position = position
	connections = []

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

extends Node

signal joueur_change_de_position(pos: Vector2)
var position_joueur: Vector2:
	set(pos):
		position_joueur = pos
		joueur_change_de_position.emit(position_joueur)
var checkpoint_depart: Checkpoint
var checkpoint_arrive: Checkpoint
var carte: Carte
var nom: String
var dommages: Array[Dommage]

class Item:
	var nom: String

class Dommage:
	var id: String
	var nom: String
	var objets_necessaires: Dictionary[Item, int]

func sauvegarder():
	pass

func lister_sauvegardes() -> Array:
	return []

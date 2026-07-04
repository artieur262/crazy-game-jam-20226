extends Node

signal joueur_change_de_position(dest: Vector2, origine: Vector2)
var position_joueur: Vector2:
	set(pos):
		joueur_change_de_position.emit(pos, position_joueur)
		position_joueur = pos
var checkpoint_depart: Checkpoint
var checkpoint_arrive: Checkpoint
var carte: Carte
var nom: String
var dommages: Array[Dommage]
var inventaire :Array[Item]


func quantite_dans_inventaire(objet:Item) -> int:
	return 0



func sauvegarder():
	pass

func lister_sauvegardes() -> Array:
	return []

func retour_chariot():
	pass

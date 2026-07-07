## Maintient la liste des items du jeu.
extends Node

## Bois utilisé pour réparer le chariot dont l'habitacle ou les roues.
var bois: = Item.new("bois", "bois", 4)
## Chambre utilisé pour réparer les rideaux
var chanvre := Item.new("chanvre", "chanvre", 1)
## Marchandise transporté par le joueur.
var marchandise := Item.new("marchandise", "marchandise", 1)

## Hache utilisé pour couper le bois.
var hache := Outil.new("hache", "hache", 3)
## Eponge utilisé pour nettoyer le chariot.
var eponge := Outil.new("eponge", "eponge", 1)
## Seau utilisé pour nettoyer le chariot.
var seau := Outil.new("seau", "seau", 2)
## Aiguilles utilisé pour réparer les rideaux.
var aiguilles := Outil.new("aiguilles", "aiguilles", 1)
## Marteau utilisé pour réparer le chariot.
var marteau := Outil.new("marteau", "marteau",2)

## Liste des items du jeu.
var items: Array[Item] = [bois, chanvre, hache, seau, aiguilles, marteau, eponge, marchandise]

## Recupère un item par son ID.
func by_id(id: String) -> Item:
	for item in items:
		if item.id == id:
			return item
	return null

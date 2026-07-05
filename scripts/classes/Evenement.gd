## Represente un évènement ayant eu lieu (généralement la nuit).
class_name GameEvent
## Nom du [GameEvent].
var nom: String
## Description du [GameEvent].
var description: String
## [Dommage]s causé par ce [GameEvent].
var impacts: Array[Dommage]
## Booléen indiquant si des vols ont été commis.
var vols: bool

func _init(arg_nom: String, arg_description: String, arg_impacts: Array[Dommage], arg_vols: bool):
	nom = arg_nom
	description = arg_description
	impacts = arg_impacts
	vols = arg_vols

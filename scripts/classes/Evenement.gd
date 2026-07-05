class_name GameEvent
var nom: String
var description: String
var impacts: Array[Dommage]
var vols: bool

func _init(arg_nom: String, arg_description: String, arg_impacts: Array[Dommage], arg_vols: bool):
	nom = arg_nom
	description = arg_description
	impacts = arg_impacts
	vols = arg_vols

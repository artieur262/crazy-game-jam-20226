## Représente un item du jeu.
class_name Item

## Id de l'item (doit être stable entre les parties).
var id: String
## Nom de l'item.
var nom: String
## Taille dans l'inventaire de l'item.
var taille: int

func _init(arg_id: String, arg_nom: String, arg_taille: int):
	id = arg_id
	nom = arg_nom
	taille = arg_taille

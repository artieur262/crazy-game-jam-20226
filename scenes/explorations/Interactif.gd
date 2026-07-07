extends StaticBody2D
class_name Interactif

enum LOOTS {
	## Utilisé pour ne pas supprimer le loot déjà défini dans la classe.
	## Ne défini pas de loot.
	NONE,
	## Change le loot utilisé par l'objet en 5 [member Items.bois].
	ARBRE,
	## Change le loot utilisé par l'objet en 3 [member Items.chanvre].
	CHANVRE
}

## Définit le loot donné par cet objet.
## Permet de définit [member donne] automatiquement. Utiliez [member LOOTS.NONE] pour définir via un script.
@export var loot := LOOTS.ARBRE
## Défini si l'item doit despawn quand il est collecté.
## Si oui ne pas indexer l'objet il peux être [member queue_free]
@export var unspawn_on_collect := false
## Défini le temp nécessaire pour récupérer l'objet.
@export var temp := 3.0
## Défini le masque utilisé pour les objet interractifs.
static var mask := 0b10
## Dictionnaire des éléments données par cet objet.
## Écrasé par [member _ready] si [member loot] n'est pas [member LOOTS.NONE]. 
var donne: Dictionary[Item, int] = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask |= mask
	collision_layer |= mask
	match loot:
		LOOTS.ARBRE:
			donne = {Items.bois: 5}
		LOOTS.CHANVRE:
			donne = {Items.chanvre: 3}


## Récupère un objet interractif.
## Si [member unspawn_on_collect] est vrai il sera [member queue_free].
func collect() -> Dictionary[Item, int]:
	if unspawn_on_collect:
		queue_free()
	return donne

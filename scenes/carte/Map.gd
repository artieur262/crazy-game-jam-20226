## UI de la carte du monde.
extends TileMapLayer
class_name Map

## Rayon (en nombre de case) autour du personnages qui seront dévoillé lors des déplacements.
@export var rayon_de_decouverte := 4
## Distance max (en pixels) entre deux [Checkpoint]
@export var distance_max := 50

## Liste des [Checkpoints] de cette [Map].
@export var checkpoints: Array[Checkpoint] = []


func _ready() -> void:
	# Jeu.position_joueur.connect(mettre_a_jour)
	Generateur.genere_routes(self)


## Connecté à [signal Jeu.position_joueur] pour mettre à jour la carte en
## fonction de la position du joueur.
func _on_joueur_change_de_position(pos: Vector2) -> void:
	decouvrir_autour(Vector2(200,200))


## Prend des coordonées globales et dévoiles les cases avec pour rayon [member rayon_de_decouverte].
## Cette fonction nécessite des position globales pour convertir une position locale en globale
## voir [method Node2D.to_global]
func decouvrir_autour(pos_globale: Vector2):
	var position_grille := local_to_map(to_local(pos_globale))
	decouvrir_autour_de_case(position_grille)


## Prend des coordonées de la case et dévoiles les cases avec pour rayon [member rayon_de_decouverte].
## Voir [method decouvrir_autour] pour utiliser des coordonées globales/locales au lieu d'une coordonée
## de tuile.
func decouvrir_autour_de_case(position_grille: Vector2i):
	for i in range(-rayon_de_decouverte+1, rayon_de_decouverte):
		for j in range(-rayon_de_decouverte+1,rayon_de_decouverte):
			erase_cell(Vector2i(position_grille.x+i, position_grille.y+j))
	

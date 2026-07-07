extends Control

## Défini la vitesse du curseur.
var vitesse_curseur :float = 20
## Indique le sens du curseur.
var sens := 1
## Indique l'index de la prochaine lettre sur laquelle le joueur devra appuyer pour la droite.
var lettre_droite := 0
## Indique l'index de la prochaine lettre sur laquelle le joueur devra appuyer pour la gauche.
var lettre_gauche := 0
## Contient la liste de lettre pour convertir un index en string.
var liste_lettre := ["A","D","Q","D","Z","S"]
## Flag indiquant si le mini-jeu est en cours.
var encour:bool=false

## Signal indiquant que le jeu a terminé.
## boole inidique si le jeu a été réussi ou non.
signal quitter(boole:bool) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Démarre le mini-jeu.
func start():
	encour=true
## Arrête le mini-jeu.
func stop():
	encour=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if encour:
		mouve_curseur(delta)
	

## Ajoute la lettre sur le label de droite.
func ajouter_texte_droite(texte:String) -> void:
	$bordure/droite/Label_droite.text = texte
	
## Ajoute la lettre sur le label de gauche.
func ajouter_texte_gauche(texte:String) -> void:
	$bordure/gauche/Label_gauche.text = texte
	
## Défini la position du curseur.
func set_curseur(value:float) -> bool:
	var cus : Panel = $"bordure/interieur-ext/interieur-int/curseur"
	var inter : Panel = $"bordure/interieur-ext/interieur-int"
		
	cus.position.x = value
	if cus.position.x < 0 :
		cus.position.x = 0
		return false
	if cus.position.x > inter.size.x:
		cus.position.x = inter.size.x
		return false
	return true
	
## Déplace le curseur du facteur donné.
func add_curseur(value:float) -> bool:
		var cus : Panel = $"bordure/interieur-ext/interieur-int/curseur"
		return set_curseur(cus.position.x + value)

## Change le sens d'avancée du curseur.
func demi_tour():
	sens = -sens

## Fait déplacer le curseur avec le delta donné.
func mouve_curseur(delta: float):
	if not add_curseur(delta*vitesse_curseur*sens):
		sens = -sens
		
## Détecte si le curseur est dans la zone donnée.		
func collision_local_x(pane1 : Panel, pane2: Panel) -> bool:
	var coin_1_p1 := pane1.position.x
	var coin_2_p1 := pane1.position.x + pane1.size.x

	var coin_1_p2 := pane2.position.x
	var coin_2_p2 := pane2.position.x + pane2.size.x

	return ((coin_1_p2 <= coin_1_p1 and coin_1_p1 < coin_2_p2) or
		(coin_1_p1 <= coin_1_p2 and coin_1_p2 < coin_2_p1))
	
## Donne la lettre associé à un event.
func traducteur(event: InputEventKey, touche:String) ->bool:
	match touche:
		"A":
			return event.keycode == KEY_A
		"Z":
			return event.keycode == KEY_Z
		"E":
			return event.keycode == KEY_E
		"R":
			return event.keycode == KEY_R
		"Q":
			return event.keycode == KEY_Q
		"S":
			return event.keycode == KEY_S
		"D":
			return event.keycode == KEY_D
		"F":
			return event.keycode == KEY_F
		"W":
			return event.keycode == KEY_W
		"X":
			return event.keycode == KEY_X
		"C":
			return event.keycode == KEY_C
		"V":
			return event.keycode == KEY_V
		"B":
			return event.keycode == KEY_B
		"N":
			return event.keycode == KEY_N
		"T":
			return event.keycode == KEY_T
		"Y":
			return event.keycode == KEY_Y
		_:
			return false
		
	

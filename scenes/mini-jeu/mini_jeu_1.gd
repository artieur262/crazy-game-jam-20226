extends "res://scenes/mini-jeu/mini_jeu.gd"

## Flag indiquant si le curseur se dirige vers la droite.
var prochain_droite := false
## Nombre de réussites à faire. 
var restant := 10



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	start()
	
## Démarre le mini-jeu.
func start():
	super.start()
	randomiser(true)
	randomiser(false)
	changer()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if traducteur(event, lettre_actuelle()):
			actioner()

## Retourne un string représentant la prochaine lettre sur laquelle appuyer.
func lettre_actuelle() -> String:
	if prochain_droite:
		return liste_lettre.get(lettre_droite)
	return liste_lettre.get(lettre_gauche)

## Change de direction le curseur..
func changer():
	prochain_droite = not prochain_droite
	var droite : Panel = $"bordure/interieur-ext/interieur-int/active_d"
	var gauche : Panel = $"bordure/interieur-ext/interieur-int/active_r"
	var p1 : Panel
	var p2 : Panel
	if prochain_droite:
		p1 = droite
		p2 = gauche
	else:
		p1 = gauche
		p2 = droite

	p1.modulate = Color.BLUE
	p2.modulate = Color.GRAY

## Augmente le nombre de point du joueur.
func point_up() -> void:
	randomiser(prochain_droite)
	changer()
	restant -=1
	if restant == 0:
		quitter.emit(true)

## Augmente le nombre de point du joueur.
func actioner():
	var cus : Panel = $"bordure/interieur-ext/interieur-int/curseur"
	var droite : Panel = $"bordure/interieur-ext/interieur-int/active_d"
	var gauche : Panel = $"bordure/interieur-ext/interieur-int/active_r"
	if prochain_droite:
		if collision_local_x(cus,droite) :
			point_up()
			
	elif collision_local_x(cus,gauche):
		point_up()

## Selectionne une lettre au hasard dans la liste de lettre pour le côté choisir et la défini comme la lettre à utiliser.
func randomiser(is_droite:bool):
	var rand := randi_range(0,liste_lettre.size()-1)
	if is_droite:
		lettre_droite=rand
		ajouter_texte_droite(liste_lettre.get(lettre_droite))
	else:
		lettre_gauche=rand
		ajouter_texte_gauche(liste_lettre.get(lettre_gauche))
	

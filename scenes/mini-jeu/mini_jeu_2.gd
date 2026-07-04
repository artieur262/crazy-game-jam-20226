extends "res://scenes/mini-jeu/mini_jeu.gd"

var temp := 3
var impultion := 100
var restant := 20


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	vitesse_curseur =1.5
	sens = -1
	set_curseur($"bordure/interieur-ext/interieur-int".size.x)
	randomiser()
	randomiser()
	$"bordure/droite".self_modulate = Color.BLUE
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	
func _input(event: InputEvent) -> void:
	if event is  InputEventKey:
		if traducteur(event,liste_lettre.get(lettre_droite)):
			jouer()

	
func jouer():
	var cur : Panel = $"bordure/interieur-ext/interieur-int/curseur"
	if cur.position.x <=0:
		quitter.emit(false)
	add_curseur(impultion)
	randomiser()
	restant-=1
	if restant ==0:
		quitter.emit(true)
	
	

func mouve_curseur():
	add_curseur(vitesse_curseur*sens)
	


	
func randomiser():
	var rand := randi_range(0,liste_lettre.size()-1)
	lettre_droite=lettre_gauche
	ajouter_texte_droite(liste_lettre.get(lettre_droite))
	lettre_gauche=rand
	ajouter_texte_gauche(liste_lettre.get(lettre_gauche))

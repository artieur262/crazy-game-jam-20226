extends Control

var vitesse_curseur :float = 3
var sens := 1
var lettre_droite := 0
var lettre_gauche := 0
var liste_lettre := ["A","D","Q","D","Z","S"]
var encour:bool=false


signal quitter(boole:bool) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func start():
	encour=true
func stop():
	encour=false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if encour:
		mouve_curseur()
	

func ajouter_texte_droite(texte:String) -> void:
	$bordure/droite/Label_droite.text = texte
	
func ajouter_texte_gauche(texte:String) -> void:
	$bordure/gauche/Label_gauche.text = texte
	
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
	
func add_curseur(value:float) -> bool:
		var cus : Panel = $"bordure/interieur-ext/interieur-int/curseur"
		return set_curseur(cus.position.x + value)

func demi_tour():
	sens = -sens

func mouve_curseur():
	if not add_curseur(vitesse_curseur*sens):
		sens = -sens
		
		
		
		
func collision_local_x(pane1 : Panel, pane2: Panel) -> bool:
	var coin_1_p1 := pane1.position.x
	var coin_2_p1 := pane1.position.x + pane1.size.x

	var coin_1_p2 := pane2.position.x
	var coin_2_p2 := pane2.position.x + pane2.size.x

	return ((coin_1_p2 <= coin_1_p1 and coin_1_p1 < coin_2_p2) or
		(coin_1_p1 <= coin_1_p2 and coin_1_p2 < coin_2_p1))
	


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
		
	

extends Node2D


func _ready():
	Jeu.reset()
	charger_noeuds()
	generer_chemins()
	queue_redraw()
	
	
func charger_noeuds():
	Jeu.noeuds.clear()

	for n in get_tree().get_nodes_in_group("noeud"):
		Jeu.noeuds.append(n)
		
func generer_chemin_principal():
	var liste = Jeu.noeuds.duplicate()
	liste.shuffle()

	for i in range(liste.size() - 1):
		creer_lien(liste[i], liste[i + 1])
		
func generer_branches():
	for n in Jeu.noeuds:
		var nb = randi_range(0, 2)

		for i in range(nb):
			var cible = Jeu.noeuds.pick_random()

			if cible != n:
				creer_lien(n, cible)
				
func creer_lien(a, b):
	a.ajouter_voisin(b)
	b.ajouter_voisin(a)

	Jeu.chemins.append([a, b])
	
func generer_chemins():
	generer_chemin_principal()
	generer_branches()
	
func _draw():
	for c in Jeu.chemins:
		var a = c[0]
		var b = c[1]

		draw_line(a.position, b.position, Color.WHITE, 3)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

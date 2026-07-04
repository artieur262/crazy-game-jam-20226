#todo: remplacer Jeu.checkpoint_depart par jeu.debut et Jeu.checkpoint_arrive par jeu.fin
class_name Generateur


## Prépare la [Carte] pour être utilisé en modifiant les connections.
static func genere_routes(carte: Carte):
	_detecter_checkpoints(carte)
	assert(len(carte.checkpoints) > 1)
	Jeu.checkpoint_depart = carte.checkpoints[0]
	Jeu.checkpoint_arrive = carte.checkpoints[len(carte.checkpoints)-1]
	_creer_connections(carte)
	var route := _choisir_route(carte)
	for checkpoint_a in carte.checkpoints:
		for checkpoint_b in checkpoint_a.liste_connection():
			var index := route.find(checkpoint_a)
			if index != 0:
				if index > 0 and route[index-1] == checkpoint_b:
					continue
				if index + 1 < len(route) and route[index+1] == checkpoint_b:
					continue
			if randi_range(0, 10) > 0:
				checkpoint_a.deconnecte_checkpoint(checkpoint_b)
		

## Cherche tout les [Checkpoint] de la [Carte].
static func _detecter_checkpoints(carte: Carte):
	for child in carte.get_children():
		if child is Checkpoint:
			carte.checkpoints.append(child)

## Créé toutes les connection entre les [Checkpoint] ayant une distance inférieure à
## [member Carte.distance_max]
static func _creer_connections(carte: Carte):
	for main_checkpoint in carte.checkpoints:
		for checkpoint in carte.checkpoints:
			if main_checkpoint.position.distance_to(checkpoint.position) < carte.distance_max:
				main_checkpoint.connecte_checkpoint(checkpoint)

## Choisi une route possible entre les [Checkpoint] et la retourne.
static func _choisir_route(carte: Carte) -> Array[Checkpoint]:
	var routes := _lister_routes([Jeu.checkpoint_depart])
	assert(len(routes) > 0)
	var route: Array[Checkpoint] = routes[randi_range(0, len(routes)-1)]
	return route

## Liste toutes les routes possible vers le [Checkpoint] de fin.
static func _lister_routes(checkpoint_visites: Array[Checkpoint]) -> Array[Array]:
	var routes: Array[Array]
	for checkpoint_connecte in Jeu.checkpoint_depart.liste_connection():
		if checkpoint_visites.has(checkpoint_connecte):
			continue
		var checkpoint_visites_copie := checkpoint_visites.duplicate()
		checkpoint_visites_copie.append(checkpoint_connecte)
		if checkpoint_connecte == Jeu.checkpoint_arrive:
			routes.append(checkpoint_visites_copie)
			continue
		routes.append_array(_lister_routes(checkpoint_visites_copie))
	return routes

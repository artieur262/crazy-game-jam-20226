#todo: remplacer map.checkpoints[0] par jeu.debut et map.checkpoints[-1] par jeu.fin
class_name Generateur

# todo: enlever ça
static var map: Map

## Prépare la [Map] pour être utilisé en modifiant les connections.
static func genere_routes(map: Map):
	Generateur.map = map
	_detecter_checkpoints(map)
	_creer_connections(map)
	var route := _choisir_route()
	for checkpoint_a in map.checkpoints:
		for checkpoint_b in checkpoint_a.liste_connection():
			var index := route.find(checkpoint_a)
			if index != 0:
				if index > 0 and route[index-1] == checkpoint_b:
					continue
				if index + 1 >= len(route) and route[index+1] == checkpoint_b:
					continue
			if randi_range(0, 10) > 0:
				checkpoint_a.deconnecte_checkpoint(checkpoint_b)
		

## Cherche tout les [Checkpoint] de la map.
static func _detecter_checkpoints(map: Map):
	for child in map.get_children():
		if child is Checkpoint:
			map.checkpoints.append(child)

## Créé toutes les connection entre les [Checkpoint] ayant une distance inférieure à
## [member Map.distance_max]
static func _creer_connections(map: Map):
	for main_checkpoint in map.checkpoints:
		for checkpoint in map.checkpoints:
			if main_checkpoint.position.distance_to(checkpoint.position) < map.distance_max:
				main_checkpoint.connecte_checkpoint(checkpoint)

## Choisi une route possible entre les [Checkpoint] et la retourne.
static func _choisir_route() -> Array[Checkpoint]:
	var routes := _lister_routes([map.checkpoints[0]])
	var route: Array[Checkpoint] = routes[randi_range(0, len(routes)-1)]
	return route

## Liste toutes les routes possible vers le [Checkpoint] de fin.
static func _lister_routes(checkpoint_visites: Array[Checkpoint]) -> Array[Array]:
	var routes: Array[Array]
	for checkpoint_connecte in map.checkpoints[0].liste_connection():
		if checkpoint_visites.has(checkpoint_connecte):
			continue
		var checkpoint_visites_copie := checkpoint_visites.duplicate()
		if checkpoint_connecte == map.checkpoints[-1]:
			checkpoint_visites.append(checkpoint_connecte)
			routes.append(checkpoint_visites)
		routes.append_array(_lister_routes(checkpoint_visites_copie))
	return routes

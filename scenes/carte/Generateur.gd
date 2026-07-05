#todo: remplacer Jeu.checkpoint_depart par jeu.debut et Jeu.checkpoint_arrive par jeu.fin
class_name Generateur

static var routes_count := 0
static var appel_count := 0


## Prépare la [Carte] pour être utilisé en modifiant les connections.
static func genere_routes(carte: Carte):
	detecter_checkpoints(carte)
	assert(len(carte.checkpoints) > 1)
	if Jeu.checkpoint_depart == null:
		Jeu.checkpoint_depart = carte.checkpoints[
			randi_range(0, len(carte.checkpoints)-1)]
	if Jeu.checkpoint_arrive == null:
		Jeu.checkpoint_arrive = carte.checkpoints[
			randi_range(0, len(carte.checkpoints)-1)]
	_creer_connections(carte)
	var route := _choisir_route()
	for checkpoint_a in carte.checkpoints:
		for checkpoint_b in checkpoint_a.liste_connection():
			var index_a := route.find(checkpoint_a)
			var index_b := route.find(checkpoint_b)
			if index_a == -1 or index_b == -1:
				pass
			elif abs(index_a-index_b) == 1:
				continue
			if randi_range(0, 4) > 0:
				checkpoint_a.deconnecte_checkpoint(checkpoint_b)
	dessiner_routes(carte, Jeu.checkpoint_depart, [])

## Cherche tout les [Checkpoint] de la [Carte].
static func detecter_checkpoints(carte: Carte):
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
static func _choisir_route() -> Array[Checkpoint]:
	routes_count = 0
	appel_count = 0
	var routes := _lister_routes(
		Jeu.checkpoint_depart, [Jeu.checkpoint_depart])
	assert(len(routes) > 0)
	var route: Array[Checkpoint] = routes[randi_range(0, len(routes)-1)]
	return route

## Liste toutes les routes possible vers le [Checkpoint] de fin.
static func _lister_routes(
		checkpoint: Checkpoint,
		checkpoint_visites: Array[Checkpoint]) -> Array[Array]:
	var routes: Array[Array]
	appel_count += 1
	if appel_count > 5000:
		return []
	for checkpoint_connecte in checkpoint.liste_connection():
		if checkpoint_visites.has(checkpoint_connecte):
			continue
		var checkpoint_visites_copie := checkpoint_visites.duplicate()
		checkpoint_visites_copie.append(checkpoint_connecte)
		if routes_count > 20:
			return routes
		if checkpoint_connecte == Jeu.checkpoint_arrive:
			routes.append(checkpoint_visites_copie)
			routes_count += 1
			continue
		routes.append_array(_lister_routes(
			checkpoint_connecte, checkpoint_visites_copie))
	return routes

## Dessine les routes sur la [Carte].
static func dessiner_routes(
		carte: Carte, depart: Checkpoint, visite: Array[Checkpoint]):
	for checkpoint in depart.liste_connection():
		if visite.has(checkpoint):
			continue
		_dessiner_route(carte, depart, checkpoint)
	visite.append(depart)
	for checkpoint in depart.liste_connection():
		if visite.has(checkpoint):
			continue
		dessiner_routes(carte, checkpoint, visite)

## Dessiner une route sur la [Carte].
static func _dessiner_route(
		carte: Carte, debut: Checkpoint, fin: Checkpoint):
	var ligne := Line2D.new()
	carte.add_child(ligne)
	ligne.width = 2
	ligne.z_index -= 2
	ligne.add_point(
		debut.position)
	ligne.add_point(
		fin.position)

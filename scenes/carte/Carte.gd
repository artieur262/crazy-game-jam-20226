## UI de la carte du monde.
extends TileMapLayer
class_name Carte

## Signal emit par les checkpoint lorsqu'un d'entre eux est cliqué.
## Voir [signal Checkpoint.selectionne]
signal checkpoint_selectionne(Checkpoint)

## Rayon (en nombre de case) autour du personnages qui seront dévoillé lors des déplacements.
@export var rayon_de_decouverte := 2
## Distance max (en pixels) entre deux [Checkpoint]
@export var distance_max := 500

## Liste des [Checkpoints] de cette [Carte].
@export var checkpoints: Array[Checkpoint] = []

## Taile de la [Carte] en nombre de case.
@export var taille_carte := Vector2i(100, 75)
## [Checkpoint] de départ de la [Carte].
@export var depart: Checkpoint
## [Checkpoint] d'arrivée de la [Carte].
@export var arrive: Checkpoint

## [Camera2D] utilisée sur cette map.
var camera: Camera2D

## Flag déterminant si un drag and drop est en cours.
var dragging := false

func _ready() -> void:
	if camera == null:
		camera = $Camera2D

## Configure le jeu avec les [Checkpoint] de départ et
## d'arrivée définit sur cette map.
func config():
	Jeu.checkpoint_depart = depart
	Jeu.checkpoint_arrive = arrive

## Exporte les données en un dictionnaire pour être sauvergardées.
## Sauvegarde la [Carte], les [Checkpoint]s.
func export() -> Dictionary:
	return {
		"carte": _export_map(),
		"checkpoints": _export_checkpoint()
	}

## Liste les tuiles decouvertes.
func _export_map():
	var tuiles_decouvertes: Array[Array]
	for x in range(taille_carte.x):
		for y in range(taille_carte.y):
			if get_cell_source_id(Vector2i(x, y)) == null:
				tuiles_decouvertes.append([x, y])
	return {
		"tuiles_decouvertes": tuiles_decouvertes,
		"depart": depart.id,
		"arrive": arrive.id
	}

## Exporte tout les [Checkcoint]s dans un liste contennant un dict
## exporte id, position, visite, [id des checkpoints connectes].
func _export_checkpoint() -> Array[Dictionary]:
	var prepare: Array = []
	for checkpoint in checkpoints:
		var checkpoints_connectes: Array[int]
		for checkpoint_connecte in checkpoint.liste_connection():
			checkpoints_connectes.append(checkpoint_connecte.id)
		prepare.append({
			"id": checkpoint.id,
			"pos": [
				checkpoint.position.x,
				checkpoint.position.y
			],
			"visite": checkpoint.visite,
			"connections": checkpoints_connectes
		})
	return prepare


## Importe les [Checkcoint]s et la [Carte].
## Peux mener à un import partiel ne pas utiliser si
## la fonctio retourne False.
func import(data) -> bool:
	if data is not Dictionary:
		return false
	if not _import_checkpoint(data.get("checkpoints")):
		return false
	return _import_carte(data.get("carte"))

## Importe les [Checkpoint]s via les données fournies.
## Peux mener à un import partiel ne pas utiliser si
## la fonctio retourne False.
func _import_checkpoint(data) -> bool:
	if data is not Array:
		return false
	# Supprimer les checkpoints qui pourraient déjà être définis.
	Generateur.detecter_checkpoints(self)
	for checkpoint in checkpoints:
		checkpoint.queue_free()
		
	# utilisé temporairement pour rapidement connecter les
	# checkpoints.
	var checkpoints_dict: Dictionary[int, Checkpoint] = {}
	# utilisé pour programmer la connection du checkpoint
	# réfécence par l'id à la liste de checkpoitn référencés
	# à l'id.
	var checkpoints_connections: Dictionary[int, Array] = {}
	# Récupère tout les checkpoints
	for checkpoint in data:
		if checkpoint is not Dictionary:
			return false
		checkpoint = checkpoint as Dictionary
		# récupération des valeurs
		var id = checkpoint.get("id", null)
		var pos = checkpoint.get("pos", null)
		var visite = checkpoint.get("visite", null)
		var connections = checkpoint.get("connections", null)
		# vérification des types
		if id is float:
			id = int(id)
		elif id is not int:
			return false
		if pos is not Array:
			return false
		pos = pos as Array
		if pos.size() != 2:
			return false
		var pos_x = pos[0]
		var pos_y = pos[1]
		if pos_x is float:
			pos_x = int(pos_x)
		elif pos_x is not int:
			return false
		if pos_y is float:
			pos_y = int(pos_y)
		elif pos_y is not int:
			return false
		pos = Vector2i(pos_x, pos_y) as Vector2i
		if visite is not bool:
			return false
		if connections is not Array:
			return false
		connections = connections as Array
		var i := 0
		var size = connections.size()
		while i < size:
			var connection = connections[i]
			if connection is float:
				connections[i] = int(connection)
			elif connection is not int:
				return false
			i += 1
		# Création du noeud.
		var checkpointNoeud = Checkpoint.new()
		checkpointNoeud.id = id
		checkpointNoeud.position = Vector2(pos_x, pos_y)
		checkpointNoeud.visite = visite
		# utilisé plus tard pour connecter les checkpoints
		# (nécessite que tout les checkpoint ai été importés)
		checkpoints_connections[id] = connections
		checkpoints_dict[id] = checkpointNoeud
		checkpoints.append(checkpointNoeud)
		add_child(checkpointNoeud)
		checkpointNoeud.z_index += 5
	# connecte les checkpoints
	for id in checkpoints_connections:
		var checkpoint := checkpoints_dict[id]
		for dest_checkpoint_id in checkpoints_connections[id]:
			if not checkpoints_dict.has(dest_checkpoint_id):
				return false
			checkpoint.connecte_checkpoint(
				checkpoints_dict[dest_checkpoint_id]
			)
	return true

## Révèles la carte selon les données fournies.
## Return false si une érreur a été trouvé dans les données.
## Peux mener à un  dévoillement partiel ne pas utiliser si
## la fonctio retourne False.
## Doit être appellé après avoir importé les checkpoints.
func _import_carte(carte) -> bool:
	if carte is not Dictionary:
		return false
	var checkpoint_depart = carte.get("depart")
	var checkpoint_arrive = carte.get("arrive")
	if checkpoint_depart is float:
		checkpoint_depart = int(checkpoint_depart)
	elif checkpoint_depart is not int:
		return false
	if checkpoint_arrive is float:
		checkpoint_arrive = int(checkpoint_arrive)
	elif checkpoint_arrive is not int:
		return false
	var found := 0
	for checkpoint in checkpoints:
		if checkpoint.id == checkpoint_depart:
			depart = checkpoint
			found += 1
		if checkpoint.id == checkpoint_arrive:
			arrive = checkpoint
			found += 1
	if found != 2:
		return false
	var tuiles = carte.get("tuiles_decouvertes")
	if tuiles is not Array:
		return false
	tuiles = tuiles as Array
	for tuile in tuiles:
		if tuile is not Array:
			return false
		tuile = tuile as Array
		if tuile.size() != 2:
			return false
		var x = tuile[0]
		var y = tuile[1]
		if x is float:
			x = int(x)
		elif x is not int:
			return false
		if y is float:
			y = int(y)
		elif y is not int:
			return false
		erase_cell(Vector2i(x, y))
	return true


## Reset le brouillard en mettant du brouillard sur toutes
## les tuiles.
func reset_brouillard() -> void:
	Jeu.joueur_change_de_position.connect(_on_joueur_change_de_position)
	for x in range(taille_carte.x):
		for y in range(taille_carte.y):
			set_cell(Vector2i(x, y), 0, Vector2i(0,0), 0)


## Reposition les [Checkpoint] pour qu'il soit centré sur les tuile.
func reposition_checkpoints():
	for checkpoint in checkpoints:
		checkpoint.position = map_to_local(
			local_to_map(checkpoint.position))

## Returne le [Checkpoint] qui est sur cette tuile.
## [null] si introuvable.
func checkpointViaTuile(pos: Vector2i) -> Checkpoint:
	for checkpoint in checkpoints:
		if local_to_map(checkpoint.position) == pos:
			return checkpoint
	return null

## Returne le [Checkpoint] qui est sur la tuile au coordonées donnée..
## [null] si introuvable.
func checkpointViaPos(pos: Vector2) -> Checkpoint:
	return checkpointViaTuile(local_to_map(pos))



## Connecté à [signal Jeu.position_joueur] pour mettre à jour la
## [Carte] en fonction des déplacements du joueur.
func _on_joueur_change_de_position(
		dest: Vector2, origine: Vector2) -> void:
	var tuile_origine := local_to_map(origine)
	var tuile_dest := local_to_map(dest)
	var distance: Vector2i = tuile_dest-tuile_origine

	var nombre_iteration: float = max(abs(distance.x), abs(distance.y), 1)
	var i = 0
	var step_x = float(distance.x)/nombre_iteration
	var step_y = float(distance.y)/nombre_iteration
	var pos := Vector2(tuile_origine)
	while i < nombre_iteration:
		pos.x += step_x
		pos.y += step_y
		decouvrir_autour_de_case(Vector2i(pos))
		i += 1
	decouvrir_autour_de_case(tuile_dest)


## Prend des coordonées globales et dévoiles les cases avec pour rayon [member rayon_de_decouverte].
## Cette fonction nécessite des position globales pour convertir une position locale en globale
## voir [method Node2D.to_global]
func decouvrir_autour(pos_globale: Vector2):
	var position_grille := local_to_map(to_local(pos_globale))
	decouvrir_autour_de_case(position_grille)


## Prend des coordonées de la case et dévoiles les cases avec pour rayon
## [member rayon_de_decouverte].  Voir [method decouvrir_autour] pour
## utiliser des coordonées globales/locales au lieu d'une coordonée
## de tuile.
func decouvrir_autour_de_case(position_grille: Vector2i):
	for i in range(-rayon_de_decouverte+1, rayon_de_decouverte):
		for j in range(-rayon_de_decouverte+1,rayon_de_decouverte):
			decouvrir(Vector2i(
				position_grille.x+i, position_grille.y+j))

## Révèle la tuile indiqué par l'argument.
func decouvrir(pos: Vector2i):
	erase_cell(pos)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event.is_action("drag"):
			dragging = event.is_pressed()
		elif event.is_action_pressed("zoom"):
			camera.modifier_zoom(0.3)
		elif event.is_action_pressed("dezoom"):
			camera.modifier_zoom(-0.3)
	if event is InputEventMouseMotion and dragging:
		camera.bouger(-event.relative)

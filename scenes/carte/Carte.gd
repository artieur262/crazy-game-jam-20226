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
@onready var camera := $Camera2D

## Flag déterminant si un drag and drop est en cours.
var dragging := false

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
		"checkpoint": _export_checkpoint()
	}

## Liste les tuiles decouvertes.
func _export_map():
	var tuiles_decouvertes: Array[Array]
	for x in range(taille_carte.x):
		for y in range(taille_carte.y):
			if get_cell_source_id(Vector2i(x, y)) == null:
				tuiles_decouvertes.append([x, y])
	return tuiles_decouvertes

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
			"pos": checkpoint.position,
			"visité": checkpoint.visite,
			"connections": checkpoints_connectes
		})
	return prepare


## Importe les [Checkcoint]s et la [Carte].
## Peux mener à un import partiel ne pas utiliser si
## la fonctio retourne False.
func _import(data: Dictionary[String, Variant]) -> bool:
	if not _import_carte(data.get("carte")):
		return false
	return _import_checkpoint(data)

## Révèles la carte selon les données fournies.
## Return false si une érreur a été trouvé dans les données.
## Peux mener à un  dévoillement partiel ne pas utiliser si
## la fonctio retourne False.
func _import_carte(carte) -> bool:
	if carte is not Array:
		return false
	for tuile in carte:
		if tuile is Array:
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
		else:
			false
	return true

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
	checkpoints = []
	for checkpoint in data:
		if checkpoint is Dictionary:
			var id = checkpoint.get("id", null)
		else:
			return false
	return false
	
	

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

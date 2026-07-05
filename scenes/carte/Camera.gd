extends Camera2D

## Dezoom max pour la camera du jeu.
## Note que le dezoom dépend aussi de si la [Carte] est assez
## grande.
@export var dezoom_max := 10
## Variable contenant la taille du viewport précalculé pour
## éviter de mettre la caméra hors de la [Carte].
@onready var taille_viewport: Vector2 = get_viewport_rect().size / zoom

## Taille de la [Carte] en pixel précaculé depuis la taille de la
##[Carte] en tuile de [member Carte.taille_carte]
var taille_map_pixel: Vector2

func _ready():
	detecter_taille_map()

## Précalcule la taille de la map en pixel depuis l'attribut
## "taille_carte" du noeud ".." et son tile_set.tile_size.
func detecter_taille_map():
	var noeux = $".."
	taille_map_pixel = Vector2(
		noeux.taille_carte.x * noeux.tile_set.tile_size.x,
		noeux.taille_carte.y * noeux.tile_set.tile_size.y)

## Bouge la caméra du Vector2 donné.
## Appelle automatiquement [member corriger_position]
func bouger(vecteur: Vector2) -> bool:
	position += vecteur
	corriger_position()
	return false

## Modifie le zoom avec le modificateur donné.
## Appel automatique à [member corriger_zoom] et
## [member corriger_position]. et recacule la taille 
## du viewport.
func modifier_zoom(modification: float) -> bool:
	var ancienne_taille := taille_viewport
	var nouveau_zoom: Vector2 = zoom + Vector2(modification, modification)
	taille_viewport = get_viewport_rect().size / nouveau_zoom
	# x et y ont le même niveau de zoom donc on en check qu'un seul..
	if nouveau_zoom.x < 0.1:
		taille_viewport = ancienne_taille
		return false
	if nouveau_zoom.x > dezoom_max:
		taille_viewport = ancienne_taille
		return false
	nouveau_zoom = corriger_zoom(nouveau_zoom)
	zoom = nouveau_zoom
	corriger_position()
	return true

## Corrige la position de la caméra pour qu'elle ne puisse
## pas montrer en dehors de la carte.
func corriger_position():
	var bord_exterieur = position + (taille_viewport/2)
	var bord_interieur = position - (taille_viewport/2)
	if bord_exterieur.x > taille_map_pixel.x:
		position.x = taille_map_pixel.x - (taille_viewport.x/2)
	elif bord_interieur.x < 0:
		position.x = taille_viewport.x/2
	if bord_exterieur.y > taille_map_pixel.y:
		position.y = taille_map_pixel.y - (taille_viewport.y/2)
	elif bord_interieur.y < 0:
		position.y = taille_viewport.y/2

## Corrige le zoom pour pas que l'extérieur de la [Carte]
## soit montré.
func corriger_zoom(nouveau_zoom: Vector2) -> Vector2:
	if taille_viewport.x > taille_map_pixel.x:
		var zoom_int = max_zoom()
		nouveau_zoom = Vector2(zoom_int, zoom_int)
	elif taille_viewport.y > taille_map_pixel.y:
		var zoom_int = max_zoom()
		nouveau_zoom = Vector2(zoom_int, zoom_int)
	taille_viewport = get_viewport_rect().size / nouveau_zoom
	return nouveau_zoom

## Calcule le zoom max pour pas que la taille de la [Carte] soit
## visible (la [Carte] n'est pas forcément entièrement visible).
func max_zoom() -> float:
	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / taille_map_pixel.x
	var zoom_y = viewport_size.y / taille_map_pixel.y
	return max(zoom_x, zoom_y)
	

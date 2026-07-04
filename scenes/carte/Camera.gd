extends Camera2D

@export var dezoom_max := 10
@onready var taille_viewport: Vector2 = get_viewport_rect().size / zoom
var min: Vector2
var taille_map_pixel: Vector2

func _ready():
	detecter_valeurs()

func detecter_valeurs():
	var noeux = $".."
	min = Vector2.ZERO
	taille_map_pixel = Vector2(
		noeux.taille_carte.x * noeux.tile_set.tile_size.x,
		noeux.taille_carte.y * noeux.tile_set.tile_size.y)

func bouger(vecteur: Vector2) -> bool:
	position += vecteur
	corriger_position()
	return false

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

func corriger_zoom(nouveau_zoom: Vector2) -> Vector2:
	if taille_viewport.x > taille_map_pixel.x:
		var zoom_int = max_zoom()
		nouveau_zoom = Vector2(zoom_int, zoom_int)
	elif taille_viewport.y > taille_map_pixel.y:
		var zoom_int = max_zoom()
		nouveau_zoom = Vector2(zoom_int, zoom_int)
	taille_viewport = get_viewport_rect().size / nouveau_zoom
	return nouveau_zoom

func max_zoom() -> float:
	var viewport_size = get_viewport_rect().size
	var zoom_x = viewport_size.x / taille_map_pixel.x
	var zoom_y = viewport_size.y / taille_map_pixel.y
	return max(zoom_x, zoom_y)
	

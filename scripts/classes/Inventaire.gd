## Représente l'invetaire du joueur.
##
## Il est possible d'itérer sur les [Item] de l'inventaire.
## Cette itération retournera qu'une seule copie de chaque [Item],
## utilisez [member quantite] pour en connaître la quantité.
class_name Inventaire

## Contenu de l'inventaire.
var contenu: Dictionary[Item, int]
## Utilisé pour les iterations stocke une copie de chaque [Item]
## présent dans l'inventaire.
var _keys: Array[Item]

## Initialize l'itération du l'inventaire.
## Itère sur une seule copie d'un [Item] pour connaître la quantité
## voir [member quantite].
func _iter_init(arg: Array) -> bool:
	_keys = contenu.keys()
	arg[0] = 0
	return contenu.size() > 0

## Passe au prochain [Item] et indique si on peux continuer
## l'itération.
func _iter_next(arg: Array) -> bool:
	arg[0] += 1
	return _keys.size() > arg[0]

## Récupère le prochain élément de l'itération.
func _iter_get(arg: Variant) -> Item:
	return _keys[arg]

## Ajoute un [Item] à l'inventaire.
## Il est possible de spécifier le nombre de copie à inclure dans l'invetaire.
func ajoute_item(item: Item, quantite_a_ajouter := 1):
	var quantite: int = contenu.get(item, 0)
	quantite += quantite_a_ajouter
	contenu[item] = quantite

## Definie la quantité d'un [Item] dans l'inventaire.
func definir_quantite(item: Item, quantite_requise: int):
	if quantite_requise == 0:
		contenu.erase(item)
		return
	contenu[item] = quantite_requise

## Supprime un [Item] de l'inventaire.
## La quantité de cet [Item] à supprimer est par défaut à 1.
## Pour supprimer toutes les copies utiliser [member definir_quantite].
func supprime_item(item: Item, quantite_a_suppr := 1):
	var quantite: int = contenu.get(item, 0)
	quantite -= quantite_a_suppr
	if quantite < 0:
		contenu.erase(item)
		return
	contenu[item] = quantite

## Retourne la quantité d'un [Item] donnés quand l'inventaire.
func quantite(item: Item) -> int:
	return contenu.get(item, 0)

## Gère la liste de dommages et les events pouvant arriver durant la nuit.
extends Node

## Dégât due à à une roue cassé causé par une attaque de monstre ou pillard.
var roue_perdue := Dommage.new(
	"roue_cassé", "roue cassé", {Items.bois:10}, [Items.marteau])
## Dégât due à aux rideaux habimé causé par une attaque de monstre ou pillard.
var rideau_habimes := Dommage.new(
	"rideau_habimes", "rideaux habimés", {Items.chanvre:10}, [Items.aiguilles])
## Dégât due à l'habitacle habimé causé par une attaque de monstre ou pillard.
var habitacle := Dommage.new(
	"habitacle", "habitacle", {Items.bois:20}, [Items.aiguilles])
## Saleté sur la charette.
## Augmente les risque de casse spontannée.
var salete := Dommage.new(
	"salete", "salete", {}, [Items.seau, Items.eponge])

## L'event tree par défaut utilisé pour déterminer ce qui doit casser pendant la nuit.
var event_tree := {
	"Attaque de monstre": {
		"description":
			"Suite à une attaque de monstre j'ai dû me réfugier dans ma charette.\n" +
			"Ils ont tenté de rentrer mais la charette a resisté mais les traces sont là.",
		"proba": [5, 10],
		"degats": {
			roue_perdue: [6, 10],
			rideau_habimes: [5, 10],
			habitacle: [5, 22]
		},
		"vols": false,
		"protection_camp": true
	},
	"Attaque de pilliard": {
		"description":
			"Des pilliard sont venus voler une partie de la cargaison et ont  " +
			"cassé des éléments de la charette..",
		"proba": [5, 10],
		"degats": {
			roue_perdue: [6, 10],
			rideau_habimes: [5, 10],
			habitacle: [5, 22]
		},
		"vols": true,
		"protection_camp": true
	},
}

## Génère des GameEvent pour et les dommages associés.
func applique() -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	for event in event_tree:
		var data = event_tree[event]
		# Imunité due au camp installé
		if Jeu.camp_pret and data["protection_camp"]:
			continue
		# prabilitée de l'event
		if randi_range(1, data["proba"][1]) > data["proba"][0]:
			continue
		# dégats et leurs probabilitées
		var impacts: Array[Dommage] = []
		for degat in data["degats"]:
			var proba = data["degats"][degat]
			if randi_range(1, proba[1]) > proba[0]:
				continue
			if degat == rideau_habimes and Jeu.dommages.count(degat) > 5:
				continue
			Jeu.dommages.append(degat)
			impacts.append(degat)
		# Si aucn dégat rien à signaler sinon générer l'event.
		if impacts == []:
			continue
		events.append(GameEvent.new(
			event,
			data["description"],
			impacts,
			data["vols"]
		))
		if data["vols"]:
			vol()
	return events


## Lance le vol dans l'inventaire.
func vol():
	var item_a_voler: Array[Item] = []
	for item in Jeu.inventaire:
		if item is not Outil:
			item_a_voler.append(item)
	if item_a_voler == []:
		Jeu.fin()
		return
	for na in range(max(item_a_voler.size()/10,1)):
		var i := randi_range(0, item_a_voler.size()-1)
		var item = item_a_voler[i]
		Jeu.inventaire.supprime_item(
			item,
			randi_range(0, max(Jeu.inventaire.quantite(item)/10, 1)))
	

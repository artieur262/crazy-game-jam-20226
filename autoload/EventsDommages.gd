extends Node

var roue_perdue := Dommage.new(
	"roue_perdu", "roue perdue", {Items.bois:10}, [Items.marteau])
var rideau_casses := Dommage.new(
	"rideau_casses", "rideaux habimés", {Items.chanvre:10}, [Items.aiguilles])
var habitacle := Dommage.new(
	"habitacle", "habitacle", {Items.bois:20}, [Items.aiguilles])
var salete := Dommage.new(
	"salete", "salete", {}, [Items.seau, Items.eponge])

var event_tree := {
	"Attaque de monstre": {
		"description":
			"Suite à une attaque de monstre j'ai dû me réfugier dans ma charette.\n" +
			"Ils ont tenté de rentré mais la charette a resisté mais les traces sont là.",
		"proba": [5, 10],
		"degats": {
			roue_perdue: [6, 10],
			rideau_casses: [5, 10],
			habitacle: [5, 22]
		},
		"vols": true,
		"protection_camp": true
	},
	"Attaque de pilliard": {
		"description":
			"Des pilliard sont venus voler une partie de la cargaison et ont au passage" +
			"cassé des éléments de la charette..",
		"proba": [5, 10],
		"degats": {
			roue_perdue: [6, 10],
			rideau_casses: [5, 10],
			habitacle: [5, 22]
		},
		"vols": true,
		"protection_camp": true
	},
}

func applique() -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	for event in event_tree:
		var data = event_tree[event]
		if Jeu.camp_pret and data["protection_camp"]:
			continue
		if randi_range(1, data["proba"][1]) > data["proba"][0]:
			continue
		var impacts: Array[Dommage] = []
		for degat in data["degats"]:
			var proba = data["degats"][degat]
			if randi_range(1, proba[1]) > proba[0]:
				continue
			impacts.append(degat)
		if impacts == []:
			continue
		events.append(GameEvent.new(
			event,
			data["description"],
			impacts,
			data["vols"]
		))
	return events

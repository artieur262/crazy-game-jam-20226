extends Node

enum PHASES {
	PREPARTIE,
	RESUME,
	PREMIERE_SELECTION,
	PHASE_UN,
	SECONDE_SELECTION,
	PHASE_DEUX,
	NUIT
}

signal joueur_change_de_position(dest: Vector2, origine: Vector2)
var position_joueur: Vector2:
	set(pos):
		joueur_change_de_position.emit(pos, position_joueur)
		position_joueur = pos
var checkpoint_depart: Checkpoint
var checkpoint_arrive: Checkpoint
var carte: Carte
var nom: String
var dommages: Array[Dommage]
var phase_actuelle: PHASES
var inventaire :Array[Item]


func quantite_dans_inventaire(objet:Item) -> int:
	return 0



func sauvegarder():
	pass

func lister_sauvegardes() -> Array:
	return []

func retour_chariot():
	pass

func prochaine_phase() -> PHASES:
	match phase_actuelle:
		PHASES.PREPARTIE: phase_actuelle = PHASES.PREMIERE_SELECTION
		PHASES.RESUME: phase_actuelle = PHASES.PREMIERE_SELECTION
		PHASES.PREMIERE_SELECTION: phase_actuelle = PHASES.PHASE_UN
		PHASES.PHASE_UN: phase_actuelle = PHASES.SECONDE_SELECTION
		PHASES.SECONDE_SELECTION: phase_actuelle = PHASES.PHASE_DEUX
		PHASES.PHASE_DEUX: phase_actuelle = PHASES.NUIT
		_: phase_actuelle = PHASES.RESUME
	return phase_actuelle

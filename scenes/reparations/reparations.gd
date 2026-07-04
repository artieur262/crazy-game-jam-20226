extends VBoxContainer

var domages_initialises: Dictionary[String, RichTextLabel]

func _ready():
	domages_initialises = {}
	for dommage in Jeu.dommages:
		ajouter_domages(dommage)

func ajouter_domages(dommage: Dommage):
	if domages_initialises.has(dommage.id):
		return
	var noeud := RichTextLabel.new()
	noeud.text += "[color=red]%s[/color]\n" % dommage.string
	noeud.text += "Nécessite:\n"
	for objet in dommage.objets_necessaires:
		noeud.text += "-%s (%d/%d)\n" % [
			objet.nom, 
			Jeu.quantite_dans_inventaire(objet),
			dommage.objets_necessaires[objet]]
	noeud.text = noeud.text.left(-1)
	domages_initialises[dommage.id] = noeud

func supprimer_dommages(dommage: Dommage):
	if not domages_initialises.has(dommage.id):
		return
	var noeud := domages_initialises[dommage.id]
	$"Main/Réparations".remove_child(noeud)

func ajouter_item(item: Item):
	pass

extends VBoxContainer

var domages_initialises: Dictionary[String, RichTextLabel]

func _ready():
	$Window.visible=false
	domages_initialises = {}
	var cat = Dommage.new()
	cat.nom="miaou !"
	cat.objets_necessaires[Items.bois] = 1
	Jeu.dommages.append(cat)
	for dommage in Jeu.dommages:
		ajouter_domages(dommage)

func ajouter_domages(dommage: Dommage):
	if domages_initialises.has(dommage.id):
		return
	var noeud := RichTextLabel.new()
	noeud.text += dommage.nom+ "\n"
	noeud.text += "Nécessite:\n"
	noeud.bbcode_enabled = true
	for objet in dommage.objets_necessaires:
		var couleur : String ="%s"
		if Jeu.inventaire.quantite(objet)<dommage.objets_necessaires[objet]:
			couleur="[color=red]%s[/color]\n" 
		noeud.text +=couleur % ("-%s (%d/%d)\n" % [
			objet.nom, 
			Jeu.inventaire.quantite(objet),
			dommage.objets_necessaires[objet]])
	noeud.text = noeud.text.left(-1)
	domages_initialises[dommage.id] = noeud
	noeud.size_flags_horizontal=Control.SIZE_FILL
	noeud.scroll_active=false
	noeud.fit_content=true
	$"Main/Réparations/B".add_child(noeud)

func supprimer_dommages(dommage: Dommage):
	if not domages_initialises.has(dommage.id):
		return
	var noeud := domages_initialises[dommage.id]
	$"Main/Réparations/B".remove_child(noeud)

func ajouter_item(item: Item):
	pass


func afficher_inventaire():
	var noeud : RichTextLabel
	for objet in Jeu.inventaire:
		noeud = RichTextLabel.new()
		noeud.bbcode_enabled = true
		noeud.text +="%d" % Jeu.quantite_dans_inventaire(objet)
		noeud.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		$Inventaires/HBoxContainer.add_child(noeud)


func _on_button_button_down() -> void:
	$"Window/mini-jeu-1".start()
	$Window.visible=true


func _on_window_close_requested() -> void:
	$"Window/mini-jeu-1".stop()
	$Window.visible=false


func _on_minijeu_1_quitter(boole: Variant) -> void:
	if boole:
		fabliquer() 
	$"Window/mini-jeu-1".stop()
	$Window.visible=false

func fabriquer():
	for dommage in Jeu.dommages:
		for object in dommage:
			Jeu.inventaire
			

extends VBoxContainer

var domages_initialises: Dictionary[String, RichTextLabel]
var dommage_selectionne: Dommage

func _ready():
	$Window.visible=false
	domages_initialises = {}
	var roue := false
	var habitacle := false
	var rideau := false
	for dommage in Jeu.dommages:
		if dommage == EventsDommages.roue_perdue:
			roue = true
		elif dommage == EventsDommages.habitacle:
			habitacle = true
		elif dommage == EventsDommages.rideau_habimes:
			rideau = true
		ajouter_domages(dommage)
	var res: Texture2D
	if rideau:
		res = preload("res://assets/reparations/chariot-pb-rideaux.png")
	elif habitacle:
		res = preload("res://assets/reparations/chariot-pb-habitacle.png")
	elif roue:
		res = preload("res://assets/reparations/chariot-pb-roue.png")
	else:
		res = preload("res://assets/reparations/chariot.png")
	$Main/Chariot.texture = res
	afficher_inventaire()

func selectionner_image():
	var roue := false
	var habitacle := false
	var rideau := false
	for dommage in Jeu.dommages:
		if dommage == EventsDommages.roue_perdue:
			roue = true
		elif dommage == EventsDommages.habitacle:
			habitacle = true
		elif dommage == EventsDommages.rideau_habimes:
			rideau = true
		ajouter_domages(dommage)
	var res: Texture2D
	if rideau:
		res = preload("res://assets/reparations/chariot-pb-rideaux.png")
	elif habitacle:
		res = preload("res://assets/reparations/chariot-pb-habitacle.png")
	elif roue:
		res = preload("res://assets/reparations/chariot-pb-roue.png")
	else:
		res = preload("res://assets/reparations/chariot.png")
	$Main/Chariot.texture = res

func ajouter_domages(dommage: Dommage):
	if domages_initialises.has(dommage.id):
		return
	var noeud := ReparationItem.new()
	noeud.text += dommage.nom+ "\n"
	noeud.text += "Nécessite:\n"
	noeud.bbcode_enabled = true
	for objet in dommage.objets_necessaires:
		var couleur : String ="%s\n"
		if Jeu.inventaire.quantite(objet)<dommage.objets_necessaires[objet]:
			couleur="[color=red]%s[/color]\n" 
		noeud.text +=couleur % ("-%s (%d/%d)" % [
			objet.nom, 
			Jeu.inventaire.quantite(objet),
			dommage.objets_necessaires[objet]])
	for objet in dommage.outils_necessaires:
		var couleur : String ="%s\n"
		if Jeu.inventaire.quantite(objet)==0:
			couleur="[color=red]%s[/color]\n" 
		noeud.text +=couleur % ("-%s (%d/%d)" % [
			objet.nom, 
			Jeu.inventaire.quantite(objet),
			1])
	noeud.text = noeud.text.left(-1)
	domages_initialises[dommage.id] = noeud
	noeud.size_flags_horizontal=Control.SIZE_FILL
	noeud.scroll_active=false
	noeud.fit_content=true
	$"Main/Réparations/B".add_child(noeud)
	noeud.reparer.connect(_on_reparer)
	noeud.dommage = dommage
	selectionner_image()

func supprimer_dommages(dommage: Dommage):
	if not domages_initialises.has(dommage.id):
		return
	var noeud := domages_initialises[dommage.id]
	$"Main/Réparations/B".remove_child(noeud)
	selectionner_image()


func afficher_inventaire():
	var noeud : RichTextLabel
	for objet in Jeu.inventaire:
		noeud = RichTextLabel.new()
		noeud.bbcode_enabled = true
		noeud.text += "%s\n%d" % [objet.nom, Jeu.inventaire.quantite(objet)]
		noeud.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		noeud.fit_content = true
		$I/Inventaire.add_child(noeud)


func _on_reparer(item: ReparationItem) -> void:
	$"Window/mini-jeu-1".stop()
	$Window.hide()
	dommage_selectionne = null
	if verificateur_peut_reparer(item.dommage):
		dommage_selectionne = item.dommage
		$"Window/mini-jeu-1".start()
		$Window.visible=true
	else:
		$Controles/Label.text = "Cliquez sur une des options ci-dessous pour la réparer." + \
			"Cette réparation est impossible."
		$Timer.start()

func _on_window_close_requested() -> void:
	$"Window/mini-jeu-1".stop()
	$Window.visible=false

func verificateur_peut_reparer(dommage: Dommage) -> bool:
	for item in dommage.objets_necessaires:
		var quantite_requise = dommage.objets_necessaires[item]
		if quantite_requise > Jeu.inventaire.quantite(item):
			return false
	for outil in dommage.outils_necessaires:
		if Jeu.inventaire.quantite(outil) == 0:
			return false
	return true


func _on_minijeu_1_quitter(reussi: Variant) -> void:
	if reussi:
		fabriquer()
	$"Window/mini-jeu-1".stop()
	$Window.hide()
	dommage_selectionne = null


func fabriquer():
	for object in dommage_selectionne.objets_necessaires:
		Jeu.inventaire.supprime_item(object,dommage_selectionne.objets_necessaires[object])
	supprimer_dommages(dommage_selectionne)
	Jeu.dommages.erase(dommage_selectionne)
	for child in $I/Inventaire.get_children():
		child.queue_free()
	afficher_inventaire()


func _on_timer_timeout() -> void:
	$Controles/Label.text = "Cliquez sur une des options ci-dessous pour la réparer."
	

func _on_button_pressed() -> void:
	$ConfirmationDialog.show()

func _on_confirmation_dialog_confirmed() -> void:
	Jeu.retour_chariot()

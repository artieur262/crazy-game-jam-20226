class_name Dommage
var id: String
var nom: String
var objets_necessaires: Dictionary[Item, int]
var outils_necessaires: Array[Outil]
static var got_error := false

func _init(
		arg_id: String,
		arg_nom: String,
		items: Dictionary[Item, int],
		outils: Array[Outil]
		) -> void:
	id = arg_id
	nom = arg_nom
	objets_necessaires = items
	outils_necessaires = outils


static func exports(dommages: Array[Dommage]):
	var exported_data := []
	for dommage in dommages:
		exported_data.append(_export(dommage))
	return exported_data

static func _export(dommage: Dommage):
	return {
		"id": dommage.id,
		"nom": dommage.nom,
		"objects_necessaires": _export_objets(dommage)
	}

static func _export_objets(dommage: Dommage) -> Dictionary[String, int]:
	var objets: Dictionary[String, int] = {}
	for objet in dommage.objets_necessaires:
		objets[objet.id] = dommage.objets_necessaires[objet]
	for outil in dommage.outils_necessaires:
		objets[outil.id] = 1
	return objets

static func imports(datas) -> Array[Dommage]:
	got_error = false
	if datas is not Array:
		got_error = true
		return []
	var importes: Array[Dommage] = []
	for data in datas:
		var importe = _import(data)
		if importe == null:
			got_error = true
			return []
		importes.append(importe)
	return importes

static func _import(data) -> Dommage:
	if data is not Dictionary:
		return null
	data = data as Dictionary
	var id = data.get("id")
	var nom = data.get("nom")
	var objets = data.get("objects_necessaires")
	if id is not String:
		return null
	if nom is not String:
		return null
	if objets is not Array:
		return null
	var dommage := Dommage.new(id, nom, {}, [])
	for id_objet in objets:
		if id_objet is not String:
			return null
		var objet: Item = Items.by_id(id_objet)
		if objet == null:
			return null
		if objet is Outil:
			dommage.outils_necessaires.append(objet)
		else:
			dommage.objets_necessaires[objet] = objets[id_objet]
	return dommage

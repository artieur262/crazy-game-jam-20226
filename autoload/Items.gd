extends Node

var bois: = Item.new("bois", "bois")
var chanvre := Item.new("chanvre", "chanvre")

var hache := Outil.new("hache", "hache")
var seau := Outil.new("seau", "seau")
var seau_eau := Outil.new("seau d'eau", "seau d'eau")
var aiguilles := Outil.new("aiguilles", "aiguilles")

var items: Array[Item] = [bois, chanvre, hache, seau, seau_eau, aiguilles]

func by_id(id: String) -> Item:
	for item in items:
		if item.id == id:
			return item
	return null

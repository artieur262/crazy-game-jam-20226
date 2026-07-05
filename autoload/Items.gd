extends Node

var bois: = Item.new("bois", "bois")
var chanvre := Item.new("chanvre", "chanvre")

var hache := Outil.new("hache", "hache")
var eponge := Outil.new("eponge", "eponge")
var seau := Outil.new("seau", "seau")
var aiguilles := Outil.new("aiguilles", "aiguilles")
var marteau := Outil.new("marteau", "marteau")

var items: Array[Item] = [bois, chanvre, hache, seau, aiguilles, marteau, eponge]

func by_id(id: String) -> Item:
	for item in items:
		if item.id == id:
			return item
	return null

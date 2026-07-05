extends RichTextLabel
class_name ReparationItem

signal reparer(ReparationItem)
var dommage: Dommage

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			reparer.emit(self)

extends RichTextLabel
class_name ReparationItem

## Signal pour indiquer qu'une réparation a été demandé.
signal reparer(ReparationItem)
## [Dommage] associé à cet entrée.
var dommage: Dommage

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			reparer.emit(self)

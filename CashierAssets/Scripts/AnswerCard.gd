extends Button
class_name AnswerCard
## Draggable UI element representing one answer option.

@export var answer_index: int = -1
@export var answer_text: String = ""
@export var selected_texture: Texture2D
@export var unselected_texture: Texture2D
@export var label: Label
@export var texturect: TextureRect
signal OnClick (AnswerCard)
func _ready() -> void:
	# Keep visual text in sync with data.
	
	if label:
		label.text = answer_text

	# Make it obvious that it can be dragged.
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func set_data(index: int, text: String) -> void:
	answer_index = index
	answer_text = text
	if label:
		label.text = answer_text



# --- Godot UI drag & drop API ---
# Called when the drag begins. Return any Variant payload you want.
#func get_drag_data(at_position: Vector2) -> Variant:
	## Create a small preview so player sees what they're dragging.
	#var preview := duplicate() as Control
	#preview.modulate.a = 0.8
	#set_drag_preview(preview)
#
	## Payload: dictionary with what the drop zone needs.
	#return {
		#"type": "answer_card",
		#"answer_index": answer_index,
		#"answer_text": answer_text
	#}


func _on_pressed() -> void:
	OnClick.emit(self)
	pass
	


func _on_focus_entered() -> void:
	texturect.texture = selected_texture


func _on_focus_exited() -> void:
		texturect.texture = unselected_texture

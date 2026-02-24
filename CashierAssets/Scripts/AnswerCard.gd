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
var _tween = create_tween()
var _selected:=false

# --- Juice tuning ---
@export var hand : TextureRect
@export var spawn_from_y: float = 80.0
## goes here on spawn
@export var drop_to_y: float = 0.0 
## goes here after spawn
@export var spawn_time: float = 0.28
@export var drop_time: float = 0.20
@export var pop_time: float = 0.18
@export var shake_time: float = 0.18

@export var normal_scale: Vector2 = Vector2(1.0, 1.0)
@export var focus_scale: Vector2 = Vector2(1.06, 1.06)

@export var normal_modulate: Color = Color(0.88, 0.88, 0.88, 1)
@export var focus_modulate: Color = Color(1, 1, 1, 1)
@export var correct_flash: Color = Color(0.60, 1.0, 0.60, 1.0)
@export var wrong_flash: Color = Color(1.0, 0.55, 0.55, 1.0)


func _ready() -> void:
	# Keep visual text in sync with data.
	hand.hide()
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




func play_spawn_in(delay: float = 0.0) -> void:
	reset_tween()

	# start below + invisible + slightly smaller
	position = Vector2(position.x, spawn_from_y)
	modulate.a = 0.0
	scale = normal_scale * 0.96

	_tween = create_tween()
	_tween.tween_interval(delay)

	# slide up with bounce
	
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position", Vector2(position.x, drop_to_y), drop_time)
	_tween.parallel().tween_property(self, "modulate:a", 0.0, drop_time)


	# fade+scale in parallel
	_tween.parallel().set_trans(_tween.TRANS_SINE).set_ease(_tween.EASE_OUT)
	_tween.parallel().tween_property(self, "modulate:a", 1.0, spawn_time * 0.75)
	_tween.parallel().tween_property(self, "scale", normal_scale, spawn_time)
func play_drop_out(delay:float =0.0) ->void:
	reset_tween()
	_tween=create_tween()
	_tween.tween_interval(delay)
	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "position", Vector2(position.x, spawn_from_y), drop_time)
	_tween.parallel().tween_property(self, "modulate:a", 0.0, drop_time)


func play_correct() -> void:
	reset_tween()

	# Pop
	_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", normal_scale * 1.14, pop_time)
	_tween.tween_property(self, "scale", normal_scale, pop_time * 0.75)

	# Flash green (separate tween so it doesn't fight scale tween)
	var flash := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	flash.tween_property(self, "modulate", correct_flash, 0.08)
	flash.tween_property(self, "modulate", focus_modulate if _selected else normal_modulate, 0.14)

func play_wrong_shake() -> void:
	reset_tween()

	var start_x := position.x
	var t := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	# quick red flash
	t.parallel().tween_property(self, "modulate", wrong_flash, 0.08)
	t.tween_property(self, "position:x", start_x - 10.0, shake_time * 0.25)
	t.tween_property(self, "position:x", start_x + 10.0, shake_time * 0.25)
	t.tween_property(self, "position:x", start_x - 6.0, shake_time * 0.25)
	t.tween_property(self, "position:x", start_x, shake_time * 0.25)
	t.parallel().tween_property(self, "modulate", focus_modulate if _selected else normal_modulate, 0.14)


func reset_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()	

func _on_focus_entered() -> void:
	print("ii am fouccs")
	hand.show();
	_selected =true
	texturect.texture = selected_texture
	reset_tween()
	_tween.set_ease(_tween.EASE_OUT).set_trans(_tween.TRANS_ELASTIC)
	_tween.tween_property(self,"scale",Vector2(1.1,1.1),0.4)
	

func _on_focus_exited() -> void:
	hand.hide();
	_selected=false
	texturect.texture = unselected_texture
	reset_tween()
	_tween.set_ease(_tween.EASE_OUT).set_trans(_tween.TRANS_ELASTIC)
	_tween.tween_property(self,"scale",Vector2(1,1),0.4)



func _on_on_click(AnswerCard: Variant) -> void:
	OnClick.emit(self)
	

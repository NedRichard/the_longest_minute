extends PanelContainer
class_name DropZone
## UI drop target: accepts AnswerCard payloads and notifies the QuizManager.

signal answer_dropped(answer_index: int, answer_text: String)

@export var enabled: bool = true

func set_enabled(value: bool) -> void:
	enabled = value
	# Optional: visually indicate enabled/disabled
	modulate = Color(1, 1, 1, 1) if enabled else Color(1, 1, 1, 0.5)


func can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if not enabled:
		return false
	if typeof(data) != TYPE_DICTIONARY:
		return false
	return data.get("type", "") == "answer_card"


func drop_data(at_position: Vector2, data: Variant) -> void:
	if not can_drop_data(at_position, data):
		return

	var idx: int = int(data.get("answer_index", -1))
	var txt: String = str(data.get("answer_text", ""))

	emit_signal("answer_dropped", idx, txt)

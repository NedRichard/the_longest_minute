extends  Resource
class_name QuestionData
@export_multiline var question_text: String = ""
@export var answers : Array[String] = []
@export var correct_answer_indices: Array[int] = []
@export var any_answer_ok: bool = false
@export var audio_stream: AudioStream

@export var answer_time_seconds: float = 20.0
@export var total_interval_seconds: float = 30.0


func validate() -> String:
	# Returns empty string if OK, otherwise an error message.
	if answers.size() < 2 or answers.size() > 4:
		return "Answers must contain 2–4 entries."
	if not any_answer_ok and correct_answer_indices.is_empty():
		return "correct_answer_indices is empty but any_answer_ok is false."
	for idx in correct_answer_indices:
		if idx < 0 or idx >= answers.size():
			return "correct_answer_indices contains an out-of-range index: %s" % idx
	if answer_time_seconds <= 0.0:
		return "answer_time_seconds must be > 0."
	if total_interval_seconds < answer_time_seconds:
		return "total_interval_seconds must be >= answer_time_seconds."
	return ""

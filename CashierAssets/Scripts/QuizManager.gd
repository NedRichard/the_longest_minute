extends Node
class_name QuizManager

## --- Assign these in Inspector ---
@export var question_bank: QuestionBank
@export var answer_card_scene: PackedScene  # drag AnswerCard.tscn here

## Node references (hook up via unique names or drag in inspector if you prefer)
@export var question_label: Label
@export var answers_container: HBoxContainer
@export var timer_label: Label 
@export var feedback_label: Label
@export var question_counter_label: Label
@export var drop_zone: DropZone 
@export var voice_player: AudioStreamPlayer 
@export var questionPopup :PanelContainer
signal  OnCorrectAnswer
signal  OnMiss
## Internal state
var _current_index: int = 0
var _current_question: QuestionData
var _answered: bool = false
var _accepting_input: bool = false
var _answer_deadline_time: float = 0.0  # engine time in seconds

## To cancel running loops when scene resets
var _session_id: int = 0


func _ready() -> void:
	feedback_label.text = ""
	timer_label.text = ""
	questionPopup.hide()
	#drop_zone.answer_dropped.connect(_on_answer_dropped)

	if question_bank == null:
		push_error("QuizManager: question_bank is not assigned.")
		return
	if answer_card_scene == null:
		push_error("QuizManager: answer_card_scene is not assigned.")
		return
	if question_bank.questions.is_empty():
		push_error("QuizManager: question_bank has no questions.")
		return

	start_quiz()


func start_quiz() -> void:
	_session_id += 1
	_current_index = 0
	_start_question(_current_index, _session_id)


func _start_question(index: int, session: int) -> void:
	if session != _session_id:
		return
	questionPopup.show()

	_current_question = question_bank.get_question(index)
	if _current_question == null:
		_finish_quiz()
		return

	var validation_error := _current_question.validate()
	if validation_error != "":
		push_error("Question %s invalid: %s" % [index, validation_error])

	# Reset state, make this seperate method
	_answered = false
	_accepting_input = true
	drop_zone.set_enabled(true)
	feedback_label.text = ""

	# UI: question counter and text
	question_counter_label.text = "%d " % [index + 1]
	question_label.text = _current_question.question_text

	# Build answer cards
	_clear_answers()
	_spawn_answers(_current_question.answers)

	# Audio: play voice-over if assigned
	#_play_voice_over(_current_question.audio_stream)

	# Timers
	_answer_deadline_time = Time.get_ticks_msec() / 1000.0 + _current_question.answer_time_seconds

	# Start update loop for timer label (non-blocking)
	_update_timer_label_loop(session)

	# Start the question lifecycle (wait for answer or timeout, then wait remainder of interval)
	_question_lifecycle_async(session)


func _clear_answers() -> void:
	for child in answers_container.get_children() :
		var card := child as AnswerCard
		card.OnClick.disconnect(_on_answer_clicked)
		child.queue_free()


func _spawn_answers(answers: Array[String]) -> void:
	for i in range(answers.size()):
		var card := answer_card_scene.instantiate() as AnswerCard
		card.set_data(i, answers[i])
		card.OnClick.connect(_on_answer_clicked)
		answers_container.add_child(card)


func _play_voice_over(stream: AudioStream) -> void:
	voice_player.stop()
	voice_player.stream = stream
	if stream != null:
		voice_player.play()


# --- Main flow async ---
func _question_lifecycle_async(session: int) -> void:
	# Run as "fire and forget" using await in an async function pattern.
	# In Godot, any function can use await; this is just to keep logic readable.
	call_deferred("_question_lifecycle_async_impl", session)


func _question_lifecycle_async_impl(session: int) -> void:
	if session != _session_id:
		return

	# 1) Wait until answered or answer time runs out.
	while session == _session_id and _accepting_input:
		var now := Time.get_ticks_msec() / 1000.0
		if now >= _answer_deadline_time:
			_on_timeout()
			break
		await get_tree().process_frame

	if session != _session_id:
		return

	# 2) Ensure total interval is respected (30s total including answer time).
	# If player answered early, wait remaining time.
	var total := _current_question.total_interval_seconds
	var remaining := maxf(0.0, _answer_deadline_time + (total - _current_question.answer_time_seconds) - (Time.get_ticks_msec() / 1000.0))

	# Alternative simpler: measure from start time; but this is explicit and data-driven.

	if remaining > 0.0:
		await get_tree().create_timer(remaining).timeout

	if session != _session_id:
		return

	# 3) Advance to next question
	_current_index += 1
	if _current_index >= question_bank.get_count():
		_current_index =0
	else:
		_start_question(_current_index, session)


func _update_timer_label_loop(session: int) -> void:
	call_deferred("_update_timer_label_loop_impl", session)

func _update_timer_label_loop_impl(session: int) -> void:
	while session == _session_id and _accepting_input:
		var now :float = float(Time.get_ticks_msec()) / 1000.0
		var remaining : float = maxf(0.0, _answer_deadline_time - now)
		timer_label.text = "Time: %.1f" % remaining
		await get_tree().process_frame

	# After answer/timeout, freeze or clear timer display as you prefer
	timer_label.text = "Time: 0.0"

func _on_answer_clicked(answercard : AnswerCard ) ->void :
	print(answercard.answer_index)
	print(answercard.answer_text)
	if not _accepting_input:
		return
		
	var is_correct := _is_answer_accepted(answercard.answer_index)

	if is_correct:
		feedback_label.text = "✅ Correct!"
		OnCorrectAnswer.emit()
	else:
		feedback_label.text = "❌ Wrong!"
		OnMiss.emit()
	_accepting_input = false
	_answered = true
	questionPopup.hide()
	_clear_answers()
# --- Input results ---
#func _on_answer_dropped(answer_index: int, answer_text: String) -> void:
	## Ignore drops after answer window ends
	#if not _accepting_input:
		#return
#
	#_accepting_input = false
	#drop_zone.set_enabled(false)
#
	#var is_correct := _is_answer_accepted(answer_index)
#
	#if is_correct:
		#feedback_label.text = "✅ Correct!"
	#else:
		#feedback_label.text = "❌ Wrong!"
#
	#_answered = true
#
	## Optional: stop VO once answered
	## voice_player.stop()


func _on_timeout() -> void:
	if not _accepting_input:
		return

	_accepting_input = false
	drop_zone.set_enabled(false)

	feedback_label.text = "⏱️ Timeout!"
	OnMiss.emit()
	_answered = false


func _is_answer_accepted(answer_index: int) -> bool:
	if _current_question.any_answer_ok:
		return true
	return _current_question.correct_answer_indices.has(answer_index)


func _finish_quiz() -> void:
	_accepting_input = false
	drop_zone.set_enabled(false)
	_clear_answers()
	question_label.text = "Quiz complete!"
	feedback_label.text = "Thanks for playing."
	timer_label.text = ""
	voice_player.stop()

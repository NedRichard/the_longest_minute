extends Node
class_name QuizManager

## --- Assign these in Inspector ---
@export var question_bank: QuestionBank
@export var answer_card_scene: PackedScene  # AnswerCard.tscn

## UI references
@export var question_label: Label
@export var answers_container: Panel
@export var timer_label: Label
@export var feedback_label: Label
@export var question_counter_label: Label
@export var drop_zone: DropZone
@export var voice_player: AudioStreamPlayer
@export var questionPopup: Panel
@export var answer_spawn_points : Array[Control] =[]
var current_answer_card : Array[AnswerCard] = []
## Timers (add as children of QuizManager and drag them in)
@export var answer_timer: Timer        # 20s window
@export var interval_timer: Timer      # 30s total per question

## Internal state
var _current_index: int = 0
var _current_question: QuestionData
var _accepting_input: bool = false
var _answered: bool = false
var currentMode : int
##Signals
signal  OnCorrectAnswer
signal  OnMiss

func  ChangeCurrentMode(value : int) -> void:
	currentMode= value
	print("in mode cashier")
func _ready() -> void:
	feedback_label.text = ""
	timer_label.text = ""
	questionPopup.hide()
	EventBus.GameModeChanged.connect(ChangeCurrentMode)
	

	# Connect timer timeouts
	if answer_timer:
		answer_timer.one_shot = true
		answer_timer.autostart = false
		answer_timer.timeout.connect(_on_answer_timer_timeout)
	else:
		push_error("QuizManager: answer_timer not assigned!")

	if interval_timer:
		interval_timer.one_shot = true
		interval_timer.autostart = false
		interval_timer.timeout.connect(_on_interval_timer_timeout)
	else:
		push_error("QuizManager: interval_timer not assigned!")

	# Optional: if you're still using drop zone
	if drop_zone:
		drop_zone.answer_dropped.connect(_on_answer_dropped)

	# Validate setup
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
	_current_index = 0
	_start_question(_current_index)


func _start_question(index: int) -> void:
	questionPopup.show()

	_current_question = question_bank.get_question(index)
	if _current_question == null:
		_finish_quiz()
		return

	var validation_error: String = _current_question.validate()
	if validation_error != "":
		push_error("Question %s invalid: %s" % [index, validation_error])

	# Reset state
	_answered = false
	_accepting_input = true
	if drop_zone:
		drop_zone.set_enabled(true)

	feedback_label.text = ""

	# UI
	question_counter_label.text = "%d" % (index + 1)
	question_label.text = _current_question.question_text

	# Build answers
	_clear_answers()
	_spawn_answers(_current_question.answers)

	# Voice over (optional)
	# _play_voice_over(_current_question.audio_stream)

	# --- Start timers ---
	# Answer window timer
	answer_timer.stop()
	#answer_timer.wait_time = _current_question.answer_time_seconds
	answer_timer.start()

	# Total question interval timer
	interval_timer.stop()
	#interval_timer.wait_time = _current_question.total_interval_seconds
	interval_timer.start()
 #this is BS
	# Enable _process so we can update the timer label smoothly
	set_process(true)


func _process(_delta: float) -> void:
	# Update countdown label using the Timer's remaining time
	if _accepting_input and answer_timer and answer_timer.is_stopped() == false:
		timer_label.text = "Time: %.1f" % answer_timer.time_left
	else:
		# After answer/timeout, you can either keep it at 0.0 or clear it
		timer_label.text = "Time: 0.0"


func _clear_answers() -> void:
	# Safe disconnect + free
	var cb := Callable(self, "_on_answer_clicked")
	current_answer_card.clear()
	for child in answers_container.get_children():
		if child is AnswerCard:
			var card := child as AnswerCard
			# Disconnect only if connected
			if card.OnClick.is_connected(cb):
				card.OnClick.disconnect(cb)
		child.queue_free()


func _spawn_answers(answers: Array[String]) -> void:
	for i in range(answers.size()):
		var card := answer_card_scene.instantiate() as AnswerCard
		card.set_data(i, answers[i])
		card.OnClick.connect(_on_answer_clicked)
		answers_container.add_child(card)
		card.position =  answer_spawn_points[i].position
		current_answer_card.append(card)
		EventBus.start_talking.emit()


func _play_voice_over(stream: AudioStream) -> void:
	voice_player.stop()
	voice_player.stream = stream
	if stream != null:
		voice_player.play()


# ---------------------------
# Answer click (your main logic)
# ---------------------------
func _on_answer_clicked(answercard: AnswerCard) -> void:
	if not _accepting_input:
		return

	_accepting_input = false
	_answered = true

	# Stop the answer timer so timeout won't fire after answering
	answer_timer.stop()

	# Disable drop zone if you use it
	if drop_zone:
		drop_zone.set_enabled(false)

	var is_correct: bool = _is_answer_accepted(answercard.answer_index)
	if is_correct:
		feedback_label.text = "✅ Correct!"
		OnCorrectAnswer.emit()
		
		
	else:
		feedback_label.text = "❌ Wrong!"
		OnMiss.emit()
		EventBus.add_strike()

	# If you want to hide popup and clear answers immediately (like you do now):
	questionPopup.hide()
	_clear_answers()


# ---------------------------
# Optional: drop zone support
# ---------------------------
func _on_answer_dropped(answer_index: int, answer_text: String) -> void:
	if not _accepting_input:
		return

	_accepting_input = false
	_answered = true
	answer_timer.stop()

	if drop_zone:
		drop_zone.set_enabled(false)

	var is_correct: bool = _is_answer_accepted(answer_index)
	feedback_label.text = "✅ Correct!" if is_correct else "❌ Wrong!"

func _unhandled_input(event: InputEvent) -> void:
	if not _accepting_input :
		return
	if not currentMode==GameModes.Mode.CASHIER:
		return
	if event.is_action_pressed("ui_left")	:
		_on_answer_clicked(current_answer_card[0])
			
	if event.is_action_pressed("ui_right")	:
		_on_answer_clicked(current_answer_card[1])
				
	if event.is_action_pressed("ui_up")	:
		_on_answer_clicked(current_answer_card[2])
		
	if event.is_action_pressed("ui_down")	:
		_on_answer_clicked(current_answer_card[3])
				
# ---------------------------
# Timer callbacks
# ---------------------------
func _on_answer_timer_timeout() -> void:
	# Fired exactly when answer time ends
	if not _accepting_input:
		return

	_accepting_input = false
	_answered = false

	if drop_zone:
		drop_zone.set_enabled(false)

	feedback_label.text = "⏱️ Timeout!"
	OnMiss.emit()
	EventBus.add_strike()
	questionPopup.hide()
	_clear_answers()


func _on_interval_timer_timeout() -> void:
	# Fired exactly when total interval ends -> advance question
	_next_question()


func _next_question() -> void:
	_current_index += 1
	if _current_index >= question_bank.get_count():
		_current_index = 0  # you currently loop back to start
	_start_question(_current_index)


func _is_answer_accepted(answer_index: int) -> bool:
	if _current_question.any_answer_ok:
		return true
	return _current_question.correct_answer_indices.has(answer_index)


func _finish_quiz() -> void:
	_accepting_input = false
	if drop_zone:
		drop_zone.set_enabled(false)

	answer_timer.stop()
	interval_timer.stop()
	set_process(false)

	_clear_answers()
	question_label.text = "Quiz complete!"
	feedback_label.text = "Thanks for playing."
	timer_label.text = ""
	voice_player.stop()

extends Node2D

#var game_scene: PackedScene = preload("res://game_scene.gd")

@export var buttonHolder:Container
@export var mum_path: NodePath
@onready var mum: Sprite2D = get_node_or_null(mum_path)

var mom_flip_tween: Tween
var _mom_base_scale: Vector2
var _mom_facing_right: bool = true  # track facing direction

signal onGameStart
var momtween: Tween
var _busy := false
var _dialog_done: bool = false
const CHAR_READ_RATE := 0.05

@onready var textbox_container: Control = $CanvasLayer3/MarginContainer
@onready var start_symbol: Label = $CanvasLayer3/MarginContainer/MarginContainer/HBoxContainer/Label2
@onready var end_symbol: Label = $CanvasLayer3/MarginContainer/MarginContainer/HBoxContainer/Label3
@onready var quote_node: CanvasItem = $CanvasLayer3/MarginContainer/MarginContainer/HBoxContainer/quote
# quote_node can be Label or RichTextLabel

enum State {BEGINING, READY, READING, FINISHED }
var current_state: State = State.BEGINING

var text_queue: Array[String] = []

var text_tween: Tween  # typewriter tween

func _ready() -> void:
	if mum:
		_mom_base_scale = mum.scale

	print("Starting state: State.READY")
	hide_textbox()

	queue_text("Oh I am so forgetful, I forgot the bread. Just wait here Nono, I will be back in just a moment.    ")
	queue_text("You are a big boy already, after all. Already eight. Maybe you can start packing our groceries already   ")
	queue_text("I will be back in just a minute   ")
	queue_text(".....")

func _process(_delta: float) -> void:
	match current_state:
		State.READY:
			if not text_queue.is_empty():
				buttonHolder.hide()
				display_text()

		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				_finish_typewriter_immediately()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				print("finished")
				if text_queue.is_empty() and not _dialog_done:
					print("finishedx2")
					_dialog_done = true
					
					momSkidadle()
					
					return
				change_state(State.READY)
				

# -------------------
# Button: Play pressed
# -------------------
func _on_play_pressed() -> void:
	if _busy:
		return
	_busy = true
	print("pressed")
	current_state = State.READY
func momSkidadle()-> void:
	print("urmom")
	if mum == null:
		push_error("mum_path not assigned or Sprite2D not found!")
		_busy = false
		
		return

	if momtween and momtween.is_valid():
		momtween.kill()

	var target := mum.global_position
	target.x = -200.0

	momtween = create_tween()
	momtween.set_trans(Tween.TRANS_ELASTIC)
	momtween.set_ease(Tween.EASE_IN_OUT)
	momtween.tween_property(mum, "global_position", target, 1.5)

	momtween.finished.connect(func():
		print("Tween finished. Mum global:", mum.global_position)
		_busy = false
		beginGame()
	)	
func beginGame()->void:
	get_tree().change_scene_to_file("res://game_scene.tscn")
func _on_exit_pressed() -> void:
	get_tree().quit()

# -------------------
# Text queue functions
# -------------------
func queue_text(next_text: String) -> void:
	text_queue.push_back(next_text)

func hide_textbox() -> void:
	start_symbol.text = ""
	end_symbol.text = ""
	_set_quote_text("")
	textbox_container.hide()

func show_textbox() -> void:
	start_symbol.text = "*"
	end_symbol.text = ""
	textbox_container.show()

func display_text() -> void:
	var next_text := text_queue.pop_front() as String
	_set_quote_text(next_text)
	_set_reveal_ratio(0.0)
	flip_mom_juicy()
	change_state(State.READING)
	show_textbox()

	_start_typewriter(next_text)

func change_state(next_state: State) -> void:
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to: State.READY")
		State.READING:
			print("Changing state to: State.READING")
		State.FINISHED:
			print("Changing state to: State.FINISHED")
			

# -------------------
# Godot 4 Typewriter (no Tween node)
# -------------------
func _start_typewriter(text: String) -> void:
	# Kill previous typing tween if any
	if text_tween and text_tween.is_valid():
		text_tween.kill()

	var duration := maxf(0.05, float(text.length()) * CHAR_READ_RATE)
	text_tween = create_tween()
	text_tween.set_trans(Tween.TRANS_LINEAR)
	text_tween.set_ease(Tween.EASE_IN_OUT)

	# We animate reveal ratio 0..1 and apply it to Label/RichTextLabel safely
	text_tween.tween_method(_apply_reveal_ratio, 0.0, 1.0, duration)

	text_tween.finished.connect(func():
		end_symbol.text = "v"
		change_state(State.FINISHED)
	)

func _finish_typewriter_immediately() -> void:
	if text_tween and text_tween.is_valid():
		text_tween.kill()
	_set_reveal_ratio(1.0)

func _apply_reveal_ratio(r: float) -> void:
	_set_reveal_ratio(r)

# -------------------
# Helpers to support Label OR RichTextLabel
# -------------------
func _set_quote_text(t: String) -> void:
	if quote_node is Label:
		(quote_node as Label).text = t
	elif quote_node is RichTextLabel:
		(quote_node as RichTextLabel).text = t

func _set_reveal_ratio(r: float) -> void:
	r = clamp(r, 0.0, 1.0)

	if quote_node is RichTextLabel:
		# RichTextLabel has visible_ratio in Godot 4
		(quote_node as RichTextLabel).visible_ratio = r
	elif quote_node is Label:
		# Label: safest is visible_characters (works reliably)
		var lbl := quote_node as Label
		var count := lbl.text.length()
		lbl.visible_characters = int(round(r * count))
		

func flip_mom_juicy() -> void:
	if mum == null:
		print("flip_mom_juicy: mum is null")
		return

	# Ensure we captured a sane base scale
	if _mom_base_scale == Vector2.ZERO:
		_mom_base_scale = mum.scale

	# Stop previous flip tween so they don't stack
	if mom_flip_tween and mom_flip_tween.is_valid():
		mom_flip_tween.kill()

	print("flip called | flip_h before:", mum.flip_h, " | scale:", mum.scale)

	# Make sure we start from base scale each time (prevents drift)
	mum.scale = _mom_base_scale

	mom_flip_tween = create_tween()
	mom_flip_tween.set_trans(Tween.TRANS_BACK)
	mom_flip_tween.set_ease(Tween.EASE_OUT)

	# 1) Squash X to 0 (turn sideways)
	mom_flip_tween.tween_property(mum, "scale:x", 0.0, 0.08)

	# 2) Toggle flip at the "thin" moment
	mom_flip_tween.tween_callback(func():
		mum.flip_h = !mum.flip_h
	)

	# 3) Expand back (bounce)
	mom_flip_tween.tween_property(mum, "scale:x", _mom_base_scale.x, 0.14)

	mom_flip_tween.finished.connect(func():
		print("flip done | flip_h after:", mum.flip_h, " | scale:", mum.scale))

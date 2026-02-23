extends Control

@export var anxious_frame: TextureRect
@export var sweat_frame: TextureRect
@export var smoke_frame: TextureRect
@onready var game_over: Control = $Control/GameOver
@onready var win: Control = $Control/Win

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventBus.strike1.connect(display_anxiety)
	EventBus.strike2.connect(display_sweat)
	EventBus.strike3.connect(display_smoke)
	EventBus.game_over.connect(display_game_over)
	EventBus.win.connect(display_win)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_anxiety() -> void:
	anxious_frame.visible = true

func display_sweat() -> void:
	sweat_frame.visible = true
	
func display_smoke() -> void:
	smoke_frame.visible = true

func display_game_over() -> void:
	game_over.visible = true

func display_win() -> void:
	win.visible = true
	

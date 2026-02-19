extends Node2D

@onready var camera_game: Camera2D = $CameraGame
@onready var camera_mom: Camera2D = $CameraMom
@onready var camera_tetris: Camera2D = $CameraTetris
@onready var camera_cashier: Camera2D = $CameraCashier
@onready var hud: Control = $HUDCanvas/HUD


var current_camera: Camera2D

var tetris_active: bool = true
var mom_active: bool = false
var cashier_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	switch_to_tetris_screen()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if tetris_active:
		if Input.is_action_just_pressed("switch_to_left_screen"):
			switch_to_mom_screen()
		if Input.is_action_just_pressed("switch_to_right_screen"):
			switch_to_cashier_screen()
	elif mom_active:
		if Input.is_action_just_pressed("switch_to_left_screen"):
			pass
		if Input.is_action_just_pressed("switch_to_right_screen"):
			switch_to_tetris_screen()
	elif cashier_active:
		if Input.is_action_just_pressed("switch_to_left_screen"):
			switch_to_tetris_screen()
		if Input.is_action_just_pressed("switch_to_right_screen"):
			pass

func switch_to_mom_screen() -> void:
	camera_game.position = camera_mom.position
	camera_mom.make_current()
	mom_active = true
	cashier_active = false
	tetris_active = false
	
func switch_to_tetris_screen() -> void:
	camera_game.position = camera_tetris.position
	camera_tetris.make_current()
	mom_active = false
	cashier_active = false
	tetris_active = true
	
func switch_to_cashier_screen() -> void:
	camera_game.position = camera_cashier.position
	camera_cashier.make_current()
	mom_active = false
	cashier_active = true
	tetris_active = false

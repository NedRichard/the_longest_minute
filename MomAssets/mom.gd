extends Sprite2D

@export var walking_sprite: Texture2D
@export var waiting_sprite: Texture2D
@onready var mom_close_up: Sprite2D = $"../MomCloseUp"

@onready var intermission_text_1: Label = $"../CanvasLayer/MarginContainer/IntermissionText1"
@onready var intermission_text_2: Label = $"../CanvasLayer/MarginContainer/IntermissionText2"
@onready var intermission_text_3: Label = $"../CanvasLayer/MarginContainer/IntermissionText3"

@onready var skip_dialogue_timer: Timer = $"../SkipDialogueTimer"

var phase: int = 1
var dialogue: int = 0
var intermission: bool = false
var can_skip_dialogue = true

var initial_scale: Vector2i
@onready var sign_mom_timer: Timer = $"../SignMomTimer"
@onready var win_text: Label = $"../CanvasLayer/MarginContainer/WinText"
@onready var sfx_squeak: AudioStreamPlayer = $"../KidHand/SFX_Squeak"

@onready var kid_animation_player: AnimationPlayer = $"../KidHand/AnimationPlayer"
var animation_target_time: float = 0.0


@export var sfx_footsteps: AudioStreamPlayer

var mom_is_walking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_scale = self.scale
	print(scale)

func _input(event: InputEvent) -> void:
	if EventBus.current_mode == GameModes.Mode.MOM:
		if event.is_action_pressed('interact'):
			if intermission == false:
				mom_walks()
				sign_mom_timer.stop()
				sign_mom_timer.start()
			else:
				if can_skip_dialogue == true:
					dialogue += 1
					can_skip_dialogue = false
					skip_dialogue_timer.start()
					print(dialogue)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mom_is_walking:
		mom_walks()
		scale += Vector2(0.005,0.005)
	else:
		if scale >= Vector2(0.055,0.055):
			scale -= Vector2(0.0001,0.0001)
	
	if intermission == true:
		mom_close_up.visible = true
		self.visible = false
		match dialogue:
			1:
				intermission_text_1.visible = true
			2:
				intermission_text_1.visible = false
				intermission_text_2.visible = true
			3:
				intermission_text_2.visible = false
				intermission_text_3.visible = true
			4:
				intermission_text_3.visible = false
				phase = 2
				intermission = false
	
	if scale >= Vector2(1.0, 1.0):
		if phase == 1:
			intermission = true
		elif phase == 2:
			self.visible = true
			mom_close_up.visible = false
			self.scale = Vector2(0.055, 0.055)
			phase = 3
		elif phase == 3:
			EventBus.win.emit()


func _on_sign_mom_timer_timeout() -> void:
	if mom_is_walking:
		mom_stops_walking()

func mom_walks() -> void:
	if !mom_is_walking:
		mom_is_walking = true
		texture = walking_sprite
		kid_animation_player.seek(animation_target_time, true)
		kid_animation_player.play('wave')
	
	if !sfx_footsteps.is_playing():
		sfx_footsteps.play()
	if !sfx_squeak.is_playing():
		sfx_squeak.play()
		
func mom_stops_walking() -> void:
	mom_is_walking = false
	animation_target_time = kid_animation_player.current_animation_position
	kid_animation_player.stop()
	texture = waiting_sprite
	sfx_footsteps.stop()
	sfx_squeak.stop()
	


func _on_skip_dialogue_timer_timeout() -> void:
	can_skip_dialogue = true

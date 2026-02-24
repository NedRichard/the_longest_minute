extends Sprite2D


@export var walking_sprite: Texture2D
@export var waiting_sprite: Texture2D

@onready var mom_close_up: Sprite2D = $"../MomCloseUp"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var press_space: TextureRect = $"../CanvasLayer/MarginContainer/PressSpaceContainer/PressSpace"

@onready var intermission_text_1: Label = $"../CanvasLayer/MarginContainer/IntermissionText1"
@onready var intermission_text_2: Label = $"../CanvasLayer/MarginContainer/IntermissionText2"
@onready var intermission_text_3: Label = $"../CanvasLayer/MarginContainer/IntermissionText3"

@onready var skip_dialogue_timer: Timer = $"../SkipDialogueTimer"

var dialogue: int = 0
var intermission: bool = false
var can_skip_dialogue = true

var initial_scale: Vector2
var initial_pos: Vector2

@onready var sign_mom_timer: Timer = $"../SignMomTimer"
@onready var win_text: Label = $"../CanvasLayer/MarginContainer/WinText"
@onready var sfx_squeak: AudioStreamPlayer = $"../KidHand/SFX_Squeak"

@onready var kid_animation_player: AnimationPlayer = $"../KidHand/AnimationPlayer"
var animation_target_time: float = 0.0


@export var sfx_footsteps: AudioStreamPlayer

var mom_is_walking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	initial_scale = self.scale
	initial_pos = self.position

func _input(event: InputEvent) -> void:
	if EventBus.current_mode == GameModes.Mode.MOM:
		if event.is_action_pressed('interact'):
			if intermission == false:
				mom_walks()
				sign_mom_timer.stop()
				sign_mom_timer.start()
				
			elif intermission == true:
				
				if can_skip_dialogue == true:
					dialogue += 1
					can_skip_dialogue = false
					press_space.visible = false
					skip_dialogue_timer.start()
					print(dialogue)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mom_is_walking:
		mom_walks()
		scale += Vector2(0.005,0.005)
		position += Vector2(0, 1.5)
	else:
		if scale >= initial_scale:
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
				intermission = false
				intermission_text_3.visible = false
				EventBus.phase = 2
				
	
	if scale >= Vector2(1.0, 1.0):
		if EventBus.phase == 1:
			intermission = true
		elif EventBus.phase == 2:
			self.visible = true
			mom_close_up.visible = false
			self.scale = Vector2(0.055, 0.055)
			self.position = initial_pos
			EventBus.phase = 3
		elif EventBus.phase == 3:
			EventBus.win.emit()


func _on_sign_mom_timer_timeout() -> void:
	if mom_is_walking:
		mom_stops_walking()

func mom_walks() -> void:
	if !mom_is_walking:
		mom_is_walking = true
		animation_player.play("walking")
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
	var anims = animation_player.get_animation_list()
	anims.erase("walking")
	animation_player.play(anims[randi() % anims.size()])
	sfx_footsteps.stop()
	sfx_squeak.stop()
	


func _on_skip_dialogue_timer_timeout() -> void:
	if intermission == true:
		can_skip_dialogue = true
		press_space.visible = true

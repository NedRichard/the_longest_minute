extends Sprite2D

@onready var background: Sprite2D = $"../Background"
@export var bg_2: Texture2D
@export var bg_3: Texture2D
@export var bg_4: Texture2D

@export var walking_sprite: Texture2D
@export var waiting_sprite: Texture2D

@onready var mom_close_up: Sprite2D = $"../MomCloseUp"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var press_space: TextureRect = $"../CanvasLayer/MarginContainer/PressSpaceContainer/PressSpace"

@onready var intermission_text_1: Label = $"../CanvasLayer/MarginContainer/IntermissionText1"
@onready var intermission_text_2: Label = $"../CanvasLayer/MarginContainer/IntermissionText2"
@onready var intermission_text_3: Label = $"../CanvasLayer/MarginContainer/IntermissionText3"

@onready var skip_dialogue_timer: Timer = $"../SkipDialogueTimer"
@onready var mom_disappear_timer: Timer = $"../MomDisappearTimer"

var dialogue: int = 0
var can_skip_dialogue = true
var mom_can_disappear = true

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
	EventBus.strike1.connect(display_bg2)
	EventBus.strike2.connect(display_bg3)
	EventBus.strike3.connect(display_bg4)

func _input(event: InputEvent) -> void:
	if EventBus.current_mode == GameModes.Mode.MOM:
		if event.is_action_pressed('interact'):
			if EventBus.intermission == false:
				mom_walks()
				sign_mom_timer.stop()
				sign_mom_timer.start()
				
			elif EventBus.intermission == true:
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
		if EventBus.phase == 1:
			scale += Vector2(0.0015,0.0015)
			position += Vector2(0, 0.6)
		elif EventBus.phase == 2:
			scale += Vector2(0.0006,0.0006)
			position += Vector2(0, 0.1)
	else:
		if scale >= initial_scale:
			if EventBus.phase == 1:
				scale -= Vector2(0.00001,0.00001)
				position -= Vector2(0, 0.006)
			elif EventBus.phase == 2:
				scale -= Vector2(0.00001,0.00001)
				position -= Vector2(0, 0.001)
	
	if EventBus.intermission == true:
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
				EventBus.intermission = false
				mom_close_up.visible = false
				intermission_text_3.visible = false
				self.visible = true
				mom_close_up.visible = false
				self.scale = initial_scale
				self.position = initial_pos
				EventBus.phase = 2
				mom_can_disappear = true
			
	if scale >= Vector2(1.0, 1.0):
		if EventBus.phase == 1:
			EventBus.intermission = true
		elif EventBus.phase == 2:
			#self.visible = true
			#mom_close_up.visible = false
			#self.scale = initial_scale
			#self.position = initial_pos
			EventBus.phase = 3
		elif EventBus.phase == 3:
			EventBus.win.emit()

func _on_sign_mom_timer_timeout() -> void:
	if mom_is_walking == true:
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
	anims.erase("idle")
	animation_player.play(anims[randi() % anims.size()])
	sfx_footsteps.stop()
	sfx_squeak.stop()
	


func _on_skip_dialogue_timer_timeout() -> void:
	if EventBus.intermission == true:
		can_skip_dialogue = true
		press_space.visible = true

func display_bg2() -> void:
	background.texture = bg_2

func display_bg3() -> void:
	background.texture = bg_3

func display_bg4() -> void:
	background.texture = bg_4


func _on_mom_disappear_timer_timeout() -> void:
	if mom_can_disappear:
		self.visible = false
		mom_can_disappear = false
		await get_tree().create_timer(10.0).timeout
		self.visible = true

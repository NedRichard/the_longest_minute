extends Sprite2D

const walking_sprite = preload("uid://bmdxw7p3ivss2")
const waiting_sprite = preload("uid://ro4007y645c2")

@onready var sign_mom_timer: Timer = $"../SignMomTimer"
@onready var win_text: Label = $"../CanvasLayer/MarginContainer/WinText"

@onready var kid_animation_player: AnimationPlayer = $"../KidHand/AnimationPlayer"
var animation_target_time: float = 0.0


@export var sfx_footsteps: AudioStreamPlayer

var mom_is_walking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact'):
		mom_walks()
		sign_mom_timer.stop()
		sign_mom_timer.start()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if mom_is_walking:
		mom_walks()
		scale += Vector2(0.0005,0.0005)
	else:
		if scale >= Vector2(0.055,0.055):
			scale -= Vector2(0.00005,0.00005)

	if scale >= Vector2(1.0, 1.0):
		win()


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
		
func mom_stops_walking() -> void:
	mom_is_walking = false
	animation_target_time = kid_animation_player.current_animation_position
	kid_animation_player.stop()
	texture = waiting_sprite
	sfx_footsteps.stop()
	

func win() -> void:
	win_text.visible = true

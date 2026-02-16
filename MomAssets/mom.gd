extends Sprite2D

const walking_sprite = preload("uid://bmdxw7p3ivss2")
const waiting_sprite = preload("uid://ro4007y645c2")

@export var sfx_footsteps: AudioStreamPlayer

@onready var win_text: Label = $"../CanvasLayer/MarginContainer/WinText"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("sign_mom"):
		scale += Vector2(0.0003,0.0003)
		texture = walking_sprite
		if !sfx_footsteps.is_playing():
			sfx_footsteps.play()
	else:
		scale -= Vector2(0.00005,0.00005)
		texture = waiting_sprite
		sfx_footsteps.stop()

	if scale >= Vector2(1.0, 1.0):
		win()

func win() -> void:
	win_text.visible = true

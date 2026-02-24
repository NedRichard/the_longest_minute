extends Node

@export var mum_path: NodePath
@onready var mum: Sprite2D = get_node_or_null(mum_path)

var momtween: Tween
var _busy := false

func _on_play_pressed() -> void:
	print("pressed")

	if _busy:
		return
	_busy = true

	if momtween and momtween.is_valid():
		momtween.kill()
	var target := mum.global_position
	target.x = -200.0  

	momtween = create_tween()
	momtween.set_trans(Tween.TRANS_SINE)
	momtween.set_ease(Tween.EASE_IN_OUT)

	momtween.tween_property(mum, "global_position", target, 1.5)

	momtween.finished.connect(func():
		print("Tween finished. Mum global:", mum.global_position)
		_busy = false
	)


func _on_exit_pressed() -> void:
	pass # Replace with function body.

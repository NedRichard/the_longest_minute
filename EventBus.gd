extends Node

var strike: int = 0

signal strike1
signal strike2
signal strike3
signal start_talking
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_strike() -> void:
	strike += 1
	
	match strike:
		1:
			strike1.emit()
		2:
			strike2.emit()
		3:
			strike3.emit()
	

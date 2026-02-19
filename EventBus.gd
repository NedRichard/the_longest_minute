extends Node

var strike: int = 0
var is_on_cooldown: bool = false

signal strike1
signal strike2
signal strike3
signal game_over

signal start_talking
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_strike() -> void:
	if !is_on_cooldown:
		start_cooldown()
		strike += 1
	
		
		match strike:
			1:
				strike1.emit()
			2:
				strike2.emit()
			3:
				strike3.emit()
			4:
				game_over.emit()

func start_cooldown() -> void:
	is_on_cooldown = true
	await get_tree().create_timer(2.0).timeout
	is_on_cooldown = false
	

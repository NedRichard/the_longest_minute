extends Node
var phase: int = 1
var strike: int = 0
var is_on_cooldown: bool = false
var current_mode: GameModes.Mode
signal strike1
signal strike2
signal strike3
signal onStrikeGained(int)
signal game_over
signal win
signal GameModeChanged(int)
signal start_talking

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_strike() -> void:
	if !is_on_cooldown:
		start_cooldown()
		strike += 1
		onStrikeGained.emit(strike)
		
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
	

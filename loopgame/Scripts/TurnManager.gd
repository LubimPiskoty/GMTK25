extends Node2D

@export var turn_entity: Node;

@export var entities: Array[CharacterMovement] = []
var turnFinished: bool = true
	
func _process(delta: float) -> void:
	if turnFinished:
		next_turn()
	
func register_entity(entity: CharacterMovement):
	if entities.find(entity) == -1:
		entities.push_back(entity)

func unregister_entity(entity: CharacterMovement):
	var idx: int = entities.find(entity)
	if idx != -1:
		entities.remove_at(idx)
		
func next_turn() -> void:
	if !entities.size():
		return
	# Get the next entity on turn
	turn_entity = entities.pop_front()
	entities.push_back(turn_entity)

	turnFinished = false
	await turn_entity.start_turn()
	await get_tree().create_timer(1.0).timeout
	await turn_entity.do_turn()
	await get_tree().create_timer(1.0).timeout
	await turn_entity.end_turn()
	await get_tree().create_timer(1.0).timeout
	turnFinished = true
	

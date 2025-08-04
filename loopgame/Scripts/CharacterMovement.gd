extends Node2D
class_name CharacterMovement

signal end_move_signal

@export var speed = 32
@export var reachedTarget: bool = true
var move_target: Vector2i

@onready var pathfinder = $"../Pathfinder"
@onready var animTree: AnimationTree = $AnimationTree

var path: PackedVector2Array
var velocity: Vector2;

func _ready() -> void:
	TurnManager.register_entity(self)
	
func _physics_process(delta: float) -> void:
	if _do_step(delta):
		set_next_move_target()
		
	animTree.set("parameters/MovementBlend/blend_position", velocity)
	
	var sprite: Sprite2D = $Sprite2D
	sprite.flip_h = velocity.x > 0 
		
		
func get_grid_pos() -> Vector2i:
	var tile_pos = pathfinder.grid_pos(transform.get_origin())
	return tile_pos

func set_next_move_target():
	reachedTarget = path.size() == 0
	if reachedTarget:
		end_move_signal.emit()
		velocity = Vector2i.ZERO
		return
	
	move_target = path[0]
	path.remove_at(0)

func _do_step(delta: float) -> bool:
	if reachedTarget:
		return false

	var direction = to_local(move_target)
	if direction.length() > speed * delta:
		velocity = direction.normalized() * speed
		position += velocity * delta
	else:
		position = move_target
		return true
	
	return false

func do_turn():
	path = pathfinder.find_path(get_grid_pos(), Vector2i(1,1))
	set_next_move_target()
	await end_move_signal
	
func start_turn():
	pass
	
func end_turn():
	pass
	

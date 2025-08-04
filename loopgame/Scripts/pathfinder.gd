extends Node2D
class_name Pathfinder

@export var tile_map: TileMapLayer
var astargrid: AStarGrid2D = AStarGrid2D.new();
@export var gridSize: int = 8
@export var cellSize: int = 16

var pathToDraw: PackedVector2Array 

func _ready() -> void:
	
	astargrid.size = Vector2i(gridSize, gridSize)
	astargrid.cell_size = Vector2i(cellSize, cellSize)

	astargrid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astargrid.jumping_enabled = true

	astargrid.update()

	_update_grid_from_tilemap()

#@export_tool_button("Update AStarGrid") var update_astargrid_button: Callable = _update_grid_from_tilemap
func _update_grid_from_tilemap() -> void:
	#	if game_map == null:
	#		push_error("[Pathfinder] No tilemap added error")
	#		return

	for i in range(astargrid.size.x):
		for j in range(astargrid.size.y):
			var id: Vector2i = Vector2i(i, j)
			# If game_map does not have a cell source id >= 0
			# then we're looking at an invalid location
			var tile_data: TileData = tile_map.get_cell_tile_data(id)
			if tile_data != null:
				var tile_type = tile_data.get_custom_data('Passable')
				astargrid.set_point_solid(Vector2i(i, j), !tile_type)
				# If looking at a location outside of the game map,
				# default to marking the cell solid so the player can't navigate
				# outside of the game map.
				# Shouldn't be an issue in this demo since grid size comes from map size
				# but something to keep in mind.
			else:
				astargrid.set_point_solid(Vector2i(i, j), true)

func find_path(start_cell: Vector2i, end_cell: Vector2i) -> PackedVector2Array: 
	if start_cell == end_cell or !astargrid.is_in_boundsv(start_cell) or !astargrid.is_in_boundsv(end_cell):
		return []

	var path: Array = astargrid.get_id_path(start_cell, end_cell).map(world_pos)
	draw_path(path)
	return path

func grid_pos(world_pos: Vector2i) -> Vector2i:
	return tile_map.local_to_map(world_pos)
	
func world_pos(grid_pos: Vector2i) -> Vector2i:
	return tile_map.map_to_local(grid_pos)

func draw_path(path: PackedVector2Array)-> void:
	pathToDraw = path.duplicate()
	queue_redraw()

func _draw() -> void:
	var opacity: float = 0.15	
	for x in range(gridSize):
		for y in range(gridSize):
			var color: Color = Color(Color.RED, opacity)
			if !astargrid.is_point_solid(Vector2i(x, y)):
				color = Color(Color.GREEN, opacity)
		
			var world: Vector2i = world_pos(Vector2i(x, y))
			world -= Vector2i(cellSize/2, cellSize/2)
			draw_rect(Rect2(world.x, world.y, cellSize, cellSize), color)

	if (pathToDraw.size() >= 2):
		draw_polyline(pathToDraw, Color.CYAN, 2)
		

extends TileMap

enum CellType { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }

var objects = []
var actors = []

var flip_dict = {96:107, 97:108, 98:108, 99:109, 100:110, 101:110, 102:111, 103:112, 104:113, 105:114, 106:115,
				 107:96, 108:97,		 109:99, 110:100,		   111:102, 112:103, 113:104, 114:105, 115:106}

var flippable_tiles = []

func _ready():
	for child in get_children():
		#set_cellv(world_to_map(child.position), child.type)
		if child.type == CellType.ACTOR:
			actors.append(child)
		elif child.type == CellType.OBJECT:
			objects.append(child)
	for id in flip_dict.keys():
		for cell in get_used_cells_by_id(id):
			flippable_tiles.append(cell)
	fade_in()
	
func fade_in():
	get_tree().paused = false
	$Tween.interpolate_property($Fader/ColorRect, "modulate:a", $Fader/ColorRect.modulate.a, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.interpolate_property($Fader/AudioStreamPlayer, "volume_db", -100, -16, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	
	$Tween.start()
	
func fade_out():
	get_tree().paused = true
	$Tween.interpolate_property($Fader/ColorRect, "modulate:a", $Fader/ColorRect.modulate.a, 1, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Fader/AudioStreamPlayer, "volume_db", $Fader/ColorRect.modulate.a, -100, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Fader/BlipPlayer.play()
	$Tween.start()


func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return(node)


func request_move(cell_start, direction):
	#var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		CellType.EMPTY:
			return true #update_pawn_position(pawn, cell_start, cell_target)
		CellType.OBJECT:
			var object_pawn = get_cell_pawn(cell_target)
			object_pawn.queue_free()
			return true #update_pawn_position(pawn, cell_start, cell_target)
		CellType.ACTOR:
			var pawn_name = get_cell_pawn(cell_target).name
			print("Cell %s contains %s" % [cell_target, pawn_name])
			
func get_range(cell_player, floor_orientation, dist, detect):
	
	var orientation = rotate90deg(floor_orientation)
	var floor_offset = get_floor_offset(floor_orientation) 
	var cell_start = cell_player + floor_offset
	var _range = range(-dist, dist)
	
	var dists = []
	
	for i in _range:
		var r = orientation * i
		var cell_target = cell_start + r
		
		var cell_target_type = get_cellv(cell_target)
		#print("check %s, i: %s" % [cell_start + (orientation * i), i])
		#print("cell_target_type: %s, search: %s, same: %s" % [cell_target_type, detect, cell_target_type == detect])
		#if detect==1 and cell_target_type == CellType.ACTOR: #to make smooching possible
		#	var true_distance = i
		#	if true_distance >= 0:
		#		true_distance = i+1
		#	dists.append(true_distance/2.0)
		#print(cell_target_type, cell_target)
		if id_to_celltype(cell_target_type) == detect:
			var true_distance = i
			if true_distance >= 0:
				true_distance = i+1
			dists.append(true_distance)
			
	if len(dists) == 0:
		return dist*2
	return abs_min(dists)
	
func id_to_celltype(id):
	if id <= 2:
		return id
	elif id < 46 or (id >= 107 and id <= 115):
		return CellType.OBSTACLE
	else: 
		return CellType.EMPTY

func get_pos(pawn):
	return world_to_map(pawn.position)
	
func abs_min(arr):
	var min_val = arr[0]
	var min_abs = abs(min_val)
	for i in range(1, arr.size()):
		if abs(arr[i]) < min_abs:
			min_val = arr[i]
			min_abs = abs(min_val)

	return min_val

func find_object_in_range(cell_player, floor_orientation, dist):
	var orientation = rotate90deg(floor_orientation)
	var floor_offset = get_floor_offset(floor_orientation) 
	var cell_start = cell_player + floor_offset - floor_orientation
	var _range = range(-dist, dist)
	var pos = []
	for i in _range:
		pos.append(cell_start + orientation*i)
	
	for obj in objects:
		var obj_pos = world_to_map(obj.position)
		if obj_pos in pos:
			return obj #[obj, _range[pos.bsearch(obj_pos)]]

func find_actor_in_range(player, cell_player, floor_orientation, dist):
	var orientation = rotate90deg(floor_orientation)
	var floor_offset = get_floor_offset(floor_orientation) 
	var cell_start = cell_player + floor_offset - floor_orientation
	var _range = range(-dist, dist)
	var pos = []
	for i in _range:
		pos.append(cell_start + orientation*i)
	
	for actor in actors:
		var apos = world_to_map(actor.position)
		if actor != player and apos in pos:
			return actor #[actor, _range[pos.bsearch(apos)]]
	

# return the first wall found in range, levels can't have two walls closer together than the range x2
func find_wall_in_range(cell_player, floor_orientation, dist):
	
	var cell_start = cell_player - floor_orientation
	
	
	return get_range(cell_start, floor_orientation, dist, CellType.OBSTACLE)
	
			#CellType.ACTOR:
			#	if i != 0 and abs(i/2)<min_range:
			#		min_range = true_distance/2
	
	
func find_hole_in_range(cell_player, floor_orientation, dist):
	#var cell_start = cell_player + floor_orientation #world_to_map(pawn.position) + floor_orientation
	
	#var orientation = rotate90deg(floor_orientation)
	#var floor_offset = get_floor_offset(floor_orientation)
	#var cell_start = cell_player + floor_offset
	
	return get_range(cell_player, floor_orientation, dist, CellType.EMPTY)
	
	
func rotate90deg(vec):
	return Vector2(vec.y, -vec.x)
	
func get_floor_offset(floor_orientation):
	if floor_orientation == Vector2.LEFT:
		return Vector2.LEFT
	elif floor_orientation == Vector2.UP:
		return Vector2.UP + Vector2.LEFT
	elif floor_orientation == Vector2.RIGHT:
		return Vector2.UP
	else:
		return Vector2()
	
func find_floor_dirs(cell_start):
	#var cell_start = world_to_map(pawn.position)
	var main_dirs = [Vector2.UP+Vector2.LEFT, Vector2.UP, Vector2.LEFT, Vector2()]
	var filled = []
	var res = []
	
	for i in range(len(main_dirs)):
		var dir = main_dirs[i]
		var cell_type = id_to_celltype(get_cellv(cell_start + dir))
		if cell_type == CellType.OBSTACLE or cell_type == CellType.ACTOR:
			filled.append( i )
	if len(filled) > 1: #wall or inner corner
		if 0 in filled and 1 in filled:
			res.append(Vector2.UP)
		if 1 in filled and 3 in filled:
			res.append(Vector2.RIGHT)
		if 0 in filled and 2 in filled:
			res.append(Vector2.LEFT)
		if 2 in filled and 3 in filled:
			res.append(Vector2.DOWN)
	elif len(filled) == 1:
		match filled[0]:
			0:
				res.append(Vector2.UP+Vector2.LEFT)
			1:
				res.append(Vector2.UP+Vector2.RIGHT)
			2:
				res.append(Vector2.DOWN+Vector2.LEFT)
			3:
				res.append(Vector2.DOWN+Vector2.RIGHT)
		
	return res


func flip(group):
	for cell in flippable_tiles:
		var id = get_cellv(cell)
		set_cellv(cell, flip_dict.get(id))

			

func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, CellType.EMPTY)
	return map_to_world(cell_target) + cell_size / 2

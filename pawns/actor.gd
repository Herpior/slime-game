extends "pawn.gd"

onready var grid = get_parent()
var state_machine
var cell_offset = Vector2()
var slime_radius = 3
var move_time = 0.13
var prev_floor = Vector2.RIGHT
var nearby_hole = null
var nearby_wall = null

func _ready():
	var floors = grid.find_floor_dirs(get_pos())
	update_look_direction(floors[0])
	state_machine = $AnimationTree.get("parameters/playback")
	state_machine.travel("idle")
	cell_offset = get_pos() - grid.get_pos(self)
	#print(grid.get_pos(self))


func _process(_delta):
	
	var pos_self = get_pos() #$Actor.get("transform/position") / 32
	var floors = grid.find_floor_dirs(pos_self)
	var can_move_to = []
	if len(floors) == 1 and floors[0].length() > 1:
		# outer corner
		can_move_to = [Vector2(floors[0].x, 0), Vector2(0, floors[0].y)]
		#update_look_direction(Vector2(0, floors[0].y))
	elif len(floors) > 0:
		#update_look_direction(floors[0])
		for f in floors:
			can_move_to += get_adj(f)
		for f in floors:
			can_move_to.erase( f )
	else:
		print("nothing")
		$Actor.get("error") #crash the game to get the debubugger up because why not, it can't progress in this state anyways
			
	
	
	var input_direction = get_input_direction()
	if not input_direction:
		return
	elif false:
		print(" ")
		print("floor_dir %s" % [grid.find_floor_dirs(pos_self)])
		print("can_move_to %s" % [can_move_to])
		print("input_direction %s" % [input_direction])
		print("pos self %s, off %s" % [pos_self, cell_offset])
	input_direction = get_best_matching_direction(input_direction, can_move_to, floors)
	if not input_direction:
		return

	#print("moves %s, move %s" % [can_move_to, input_direction])
	
	var target_position = pos_self + input_direction
	#var move = grid.request_move(pos_self, input_direction)
	#if move:
	move_to(target_position)
	#else:
	#	pass
		#bump()

func get_adj(direction):
	var flipped = Vector2(direction.y, direction.x)
	return [flipped, -flipped]
	
func get_best_matching_direction(input_dir, possible_moves, floor_dirs):
	var hori = Vector2(input_dir.x, 0)
	var vert = Vector2(0, input_dir.y)
	if hori in possible_moves and vert in possible_moves:
		pass
	elif hori in possible_moves:
		return hori
	elif vert in possible_moves:
		return vert
	# it's difficult to see from the animation if you are exactly at the corner
	# so let's help the player by letting them move closer to the edge/wall
	# when they are trying to move to the direction after the corner.
	# it feels really good
	elif nearby_hole and hori in floor_dirs or vert in floor_dirs:
		return nearby_hole
	elif nearby_wall and -hori in floor_dirs or -vert in floor_dirs:
		return nearby_wall
		
		

func get_input_direction():
	var in_x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var in_y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if Input.is_mouse_button_pressed(1):
		var vp = get_viewport()
		var mouse_input = get_global_mouse_position() - self.position #0.5 * vp.size
		if (abs(mouse_input.x * 2.0 / vp.size.x) > 0.2):
			in_x += mouse_input.x * 2.0 / vp.size.x
		if (abs(mouse_input.y * 2.0 / vp.size.x) > 0.2):
			in_y += mouse_input.y * 2.0 / vp.size.y
	# there are problems with gamepads if the input is not normalized -> normalize it
	# also lets me just add mouse input to other inputs without breaking things
	if abs(in_x) > 0:
		in_x = in_x/abs(in_x)
	if abs(in_y) > 0:
		in_y = in_y/abs(in_y)
	return Vector2( in_x, in_y )


func update_look_direction(direction):
	$Pivot.rotation = direction.angle()-PI/2 #/Sprite.rotation = direction.angle()-PI/2
	
func get_pos():
	return (position) /64 - cell_offset
	
func to_position(cell_pos):
	return (cell_pos + cell_offset) * 64


func move_to(target_position):
	set_process(false)
	var pos_self = get_pos()
	# Move the node to the target cell instantly,
	# and animate the sprite moving from the start to the target cell
	var move_direction = (target_position - pos_self).normalized()
	#$Tween.interpolate_property($Pivot, "position", - move_direction * 32, Vector2(), move_time, Tween.TRANS_LINEAR)
	$Tween.interpolate_property(self, "position", null, to_position(target_position), move_time, Tween.TRANS_LINEAR)
	#$Tween.interpolate_property($Pivot, "scale", Vector2(1, 1), Vector2(1.2, 0.8), move_time, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	#position = target_position

	$Tween.start()
	
	var floor_dirs = grid.find_floor_dirs(target_position)
	var floor_dir = floor_dirs[0]
	if prev_floor in floor_dirs:
		floor_dir = prev_floor
	elif floor_dir.length() > 1:
		# outer corner use previous floor or up/down as floor
		if prev_floor in [Vector2(0, floor_dir.y), Vector2(floor_dir.x, 0)]:
			floor_dir = prev_floor
		else:
			floor_dir = Vector2(0, floor_dir.y)
	
	
	
	var obj_in_range = grid.find_object_in_range(target_position, floor_dir, slime_radius-1)
	var slime_in_range = grid.find_actor_in_range(self, target_position, floor_dir, slime_radius*2)
	if obj_in_range and obj_in_range.obj_type == ObjType.LEVER:
		var move = (move_direction.angle() + floor_dir.angle()) > 0 and (move_direction.angle() + floor_dir.angle()) < PI
		if floor_dir == Vector2.RIGHT:
			move = (move_direction.angle() - floor_dir.angle()) < 0
		
		#print(obj_in_range.obj_type)
		# there's a bug that lets player flip switch without going through it but let's just call it a feature
		print([move_direction, move_direction.angle(), floor_dir, floor_dir.angle(), move])
		obj_in_range.flip(int(move)*2-1)
	elif obj_in_range and obj_in_range.obj_type == ObjType.TELEPORTER:
		obj_in_range.teleport()
	
	
	var wall_in_range = grid.find_wall_in_range(target_position, floor_dir, slime_radius)
	var hole_in_range = grid.find_hole_in_range(target_position, floor_dir, slime_radius)
	if abs(hole_in_range) == 2:
		nearby_hole = grid.rotate90deg(floor_dir) * hole_in_range / 2
	else:
		nearby_hole = null
	if abs(wall_in_range) == 2:
		nearby_wall = grid.rotate90deg(floor_dir) * wall_in_range / 2
	else:
		nearby_wall = null
	#print("wall: %s hole: %s" % [wall_in_range, hole_in_range])
	
	
	if abs(wall_in_range) <= slime_radius:
		#var reverse = (move_direction.x<0 or move_direction.y<0) != (wall_in_range<0)
		var num = int(abs(wall_in_range))
		
		var state = "finished w"+str(num)
		state_machine.travel(state)
	elif abs(hole_in_range) <= slime_radius:
		#var reverse = (move_direction.x<0 or move_direction.y<0) != (hole_in_range<0)
		var num = int(abs(hole_in_range))
		
		var state = "finished o"+str(num)
		state_machine.travel(state)
	else:
		state_machine.travel("idle")
		#$AnimationPlayer.play("walk")
		#print("yielding")
		# Stop the function execution until the animation finished
		#yield($AnimationPlayer, "animation_finished")
		
	if (wall_in_range < 0) and (abs(wall_in_range) < abs(hole_in_range)):
		$Pivot.set_scale(Vector2(1,1))#/Sprite.set_flip_h(false)
	elif (hole_in_range) < 0:
		$Pivot.set_scale(Vector2(-1,1))#/Sprite.set_flip_h(true)
	elif (wall_in_range) > 0 and (wall_in_range) <= slime_radius and (abs(wall_in_range) < abs(hole_in_range)):
		$Pivot.set_scale(Vector2(-1,1))#/Sprite.set_flip_h(true)
	elif (hole_in_range) > 0 and (hole_in_range) <= slime_radius :
		$Pivot.set_scale(Vector2(1,1))#/Sprite.set_flip_h(false)
	#else: #maybe it doesn't matter which way the idle is?
	#	$Pivot/Sprite.set_flip_h(false)
	update_look_direction(floor_dir)
	prev_floor = floor_dir
	
	
		
	var t = Timer.new()
	t.set_wait_time(move_time)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	set_process(true)
	#print("done")
	


func bump():
	set_process(false)
	$AnimationPlayer.play("bump")
	yield($AnimationPlayer, "animation_finished")
	set_process(true)

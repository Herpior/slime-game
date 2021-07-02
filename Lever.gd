extends "res://pawns/pawn.gd"

onready var grid = get_parent()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var state_machine
var state = "left"

export(int) var group = 1
export(String) var start_dir = "left"

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
	state_machine.travel(start_dir + "_start")
	state = start_dir


func flip(dir):
	if dir > 0 and state != "left":
		set_state("left")
	elif dir < 0 and state != "right":
		set_state("right")
	
func set_state(dirname):
	state_machine.travel(dirname)
	state = dirname
	var t = Timer.new()
	t.set_wait_time(0.12)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	grid.flip(group)
	
		# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends "res://pawns/pawn.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(String) var next_level = "res://Level_1.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if Input.is_mouse_button_pressed(1):
		var vp = get_viewport()
		# copypasted from my mouse input code at last minute lmao, it works close emough.
		var mouse_input = get_global_mouse_position() - self.position - Vector2(0, 200) #0.5 * vp.size
		if (abs(mouse_input.x * 2.0 / vp.size.x) < 0.2) and (abs(mouse_input.y * 2.0 / vp.size.y) < 0.2):
			$AnimationPlayer.play("Clicked")
			var t = Timer.new()
			t.set_wait_time(0.5)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			
			get_parent().fade_out()
			
			t.set_wait_time(1.2)
			t.set_one_shot(true)
			t.start()
			yield(t, "timeout")
			t.queue_free()
			get_tree().change_scene(next_level)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

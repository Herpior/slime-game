extends "res://pawns/pawn.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(String) var next_level = "res://Game.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$Tween.interpolate_property(, "modulate:a", $Fader/ColorRect.modulate.a, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
	#$Tween.start()

func teleport():
	get_parent().fade_out()
	var t = Timer.new()
	t.set_wait_time(1.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()
	get_tree().change_scene(next_level)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends CPUParticles2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var style = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_material(load("res://arts/shaders/Style%d.tres" % style))
	$CPUParticles2D4.set_material(load("res://arts/shaders/Style%d.tres" % style))
	yield(get_tree().create_timer(0.4), "timeout")
	set_emitting(true)
	$CPUParticles2D4.set_emitting(true)
	yield(get_tree().create_timer(1.2), "timeout")
#	var p = load("res://objects/VFX/parti2.tscn").instance()
#	#p.set_global_position(Vector2(get_global_position().x-235.969,get_global_position().y-235.969))
#	p.set_material(load("res://arts/shaders/Style%d.tres" % style))
#	get_parent().add_child(p)
	#yield(get_tree().create_timer(0.7), "timeout")
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

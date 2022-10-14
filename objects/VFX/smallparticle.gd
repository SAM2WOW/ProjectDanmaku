extends CPUParticles2D

var style = 0

func _ready():
	set_material(load("res://arts/shaders/Style%d.tres" % Global.current_style))
	$CPUParticles2D3.set_material(load("res://arts/shaders/Style%d.tres" % style))
	set_emitting(true)
	$CPUParticles2D3.set_emitting(true)
	yield(get_tree().create_timer(0.7), "timeout")
	queue_free()

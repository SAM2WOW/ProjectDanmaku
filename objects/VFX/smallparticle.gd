extends CPUParticles2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_emitting(true)
	yield(get_tree().create_timer(0.7), "timeout");

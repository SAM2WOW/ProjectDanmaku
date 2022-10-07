extends Node2D


var speed = 300

func _physics_process(delta):
	move_local_x(delta * speed)
	#rotate(delta * 3)
	
	$Polygon2D.rotate(delta * 3)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

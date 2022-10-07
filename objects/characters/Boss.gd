extends KinematicBody2D


func damage(amount):
	print("Boss have been damaged %d" % amount)
	
	queue_free()

extends RigidBody2D


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Boss" in body.name:
		body.damage(10)
		
		queue_free()

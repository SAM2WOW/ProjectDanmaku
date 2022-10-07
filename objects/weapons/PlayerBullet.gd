extends RigidBody2D


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Boss" in body.name:
		body.damage(10)
		
		queue_free()

func _on_Verse_Jump(verse):
	match verse:
		0:
			get_node("Style0").show()
			get_node("Style1").hide()
			get_node("Style2").hide()
		1:
			get_node("Style0").hide()
			get_node("Style1").show()
			get_node("Style2").hide()
		2:
			get_node("Style0").hide()
			get_node("Style1").hide()
			get_node("Style2").show()

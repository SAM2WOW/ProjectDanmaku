extends RigidBody2D

var style = 0


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Boss" in body.name:
		body.damage(10)
		
		queue_free()


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(2):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)
	

extends KinematicBody2D

var style = 0


func damage(amount):
	print("Boss have been damaged %d" % amount)
	
	queue_free()


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(2):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)

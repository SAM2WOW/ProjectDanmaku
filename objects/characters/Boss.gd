extends KinematicBody2D

var style = 0


var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")


func damage(amount):
	print("Boss have been damaged %d" % amount)


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(2):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)


func _on_FireTimer_timeout():
	# fire bullets
	var b = basic_bullet.instance()
	
	b.style = style
	b._on_Verse_Jump(style)
	
	get_parent().add_child(b)
	b.set_global_position(get_global_position())
	
	var dir = get_global_position().direction_to(Global.player.get_global_position())
	b.add_force(Vector2.ZERO, dir * 200)

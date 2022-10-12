extends KinematicBody2D

var style = Global.initial_style
var hit_by = []

var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")


func damage(amount):
	print("Boss have been damaged %d" % amount)
	Global.console.damage_boss(amount)


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)

func fireLaserBeam():
	var laserInd = get_node("Style2/LaserIndicator")
	laserInd.set_cast_to(Global.player.get_global_position())

func _on_FireTimer_timeout():
	# fire bullets
	var b = basic_bullet.instance()
	
	if style == 2:
		fireLaserBeam()
	
	b.style = style
	b._on_Verse_Jump(style)
	
	get_parent().add_child(b)
	b.set_global_position(get_global_position())
	
	var dir = get_global_position().direction_to(Global.player.get_global_position())
	b.rotation = 2*PI + atan2(dir.y, dir.x);
	b.set_linear_velocity(dir*200);

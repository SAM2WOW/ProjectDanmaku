extends KinematicBody2D

var style = Global.initial_style
var hit_by = []
var attack_pattern = 0;
onready var fire_timer = get_node("FireTimer");

var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")

var laserInd = preload("res://objects/weapons/LaserIndicator.tscn")
var laserBeam = preload("res://objects/weapons/LaserBeam.tscn")


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

func fireLaser(fireAt):
	
	var ind = laserInd.instance();
	var timeBeforeBeam = 0.8
	var beamDuration = 0.5
	var particleDuration = 1
	
	get_parent().add_child(ind)
	ind.set_global_position(get_global_position())
	
	ind.add_point(Vector2(0,0))
#	ind.add_point(get_global_position())
	# Makes sure laser always extends past viewport
	ind.add_point((fireAt - get_global_position()))
	
	yield(get_tree().create_timer(timeBeforeBeam), "timeout")
	
	var beam = laserBeam.instance();
	beam.set_global_position(get_global_position())
	get_parent().add_child(beam)
	var beamPoint = ind.points[1]
	beamPoint[1] /= 5
	beam.set_cast_to(beamPoint)
	
	ind.queue_free()
	yield(get_tree().create_timer(beamDuration), "timeout")
	beam.is_casting = false
	
	yield(get_tree().create_timer(particleDuration), "timeout")
	beam.queue_free()

func _on_FireTimer_timeout():
	fire_bullets();

func fire_bullets():
	match style:
		0:
			init_minimal_bullets();
		1:
			init_pixel_bullets();
		2:
			init_3d_bullets();
		3:
			init_collage_bullets();
		_:
			init_minimal_bullets();
			# b.init_normal_bullet(get_global_position(), style);

# boss will have two attacks per style

# 0.) shoot like 4~ waves of minimal bullets around boss
# 1.) gatling 3~ waves of blobs of bullets towards the players position at fire
func init_minimal_bullets():
	match attack_pattern:
		0:
			var num_waves = 4;
			var wave_interval = 0.3;
			var offset_inc = 10;
			# instantiate the bullets
			# set the bullets properties to the one of the style
			for i in num_waves:
				fire_pulse(get_global_position(), 8, 300, offset_inc*i, style);
				yield(get_tree().create_timer(wave_interval), "timeout");
			fire_timer.start();
		1:
			pass
		_:
			pass

# 0: fire a wave of 4~ bullets towards the players position on firing, and blow them up when they reach there
# 1: fire a series of bullets that; start from the center and extend to the outside.
func init_pixel_bullets():
	pass

# 0: fires a wave of 4~ quick lasers towards the players position
# 1: shoot lasers in all directions, then rotate the lasers slowly around the boss (hades style)
func init_3d_bullets():
#	fireLaserBeam(Global.player.get_global_position())
	match attack_pattern:
		0:
			var timeBetweenAttacks = 1.5
			var beamDuration = 0.5
			var maxX = get_viewport().size.x / 2
			var maxY = get_viewport().size.y / 2
			var xArr = [0, maxX, -maxX]
			var yArr = [0, maxY, -maxY]
			for x in xArr:
				for y in yArr:
					# Don't shoot a laser at (0,0)
					if (x!=0 || y!=0):
						fireLaser(Vector2(x,y))
			yield(get_tree().create_timer(timeBetweenAttacks), "timeout")
			
			var xArr2 = [maxX, -maxX, maxX / 2, -maxX / 2]
			var yArr2 = [maxY, -maxY, maxY / 2, -maxY / 2]
			for x2 in xArr2:
				for y2 in yArr2:
					if (!(abs(x2) == maxX && abs(y2) == maxY) && !(abs(x2) == maxX/2 && abs(y2) == maxY/2)):
						fireLaser(Vector2(x2,y2))
			yield(get_tree().create_timer(beamDuration), "timeout")
			fire_timer.start()
		1:
			pass
		_:
			pass
	fire_timer.start()

# 0: fire 2~ waves of shotgun shots of bouncing bullets towards the player
# 1: tbf
func init_collage_bullets():
	pass

func fire_pulse(pos, num, speed, offset, _style):
	var degrees = 360.0/num;
	for i in num:
		var b = basic_bullet.instance();
		var radians = (offset+(i*degrees))*PI/180;
		var dir = Vector2(cos(radians), sin(radians));
		b.init_bullet(get_global_position(), dir, _style);
		b.set_linear_velocity(b.dir*speed);
		
		get_parent().add_child(b);

# 6~ bullets at the approximate position of the player
# dir and speed are randomized within a range
func fire_blob():
	pass

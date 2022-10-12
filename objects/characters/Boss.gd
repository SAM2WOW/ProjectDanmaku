extends KinematicBody2D

var style = Global.initial_style
var hit_by = []
var attack_pattern = 0;

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
				fire_pulse(get_global_position(), 8, offset_inc*i, style);
				yield(get_tree().create_timer(wave_interval), "timeout");
			get_node("FireTimer").start();
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
	pass

# 0: fire 2~ waves of shotgun shots of bouncing bullets towards the player
# 1: tbf
func init_collage_bullets():
	pass

func fire_pulse(pos, num, offset, _style):
	var degrees = 360.0/num;
	for i in num:
		var b = basic_bullet.instance();
		var radians = (offset+(i*degrees))*PI/180;
		b.dir = Vector2(cos(radians), sin(radians));
		b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
		b.set_global_position(get_global_position());
		get_parent().add_child(b);
		b.init_style(_style);
		b.set_linear_velocity(b.dir*300);

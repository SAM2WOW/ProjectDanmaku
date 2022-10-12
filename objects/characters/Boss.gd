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
	fire_bullet();

func fire_bullet():
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

# 1.) shoot like 4-5 waves of minimal bullets around boss
# 2.) yo mama
func init_minimal_bullets():
	match attack_pattern:
		0:
			# instantiate the bullets
			# set the bullets properties to the one of the style
			var bullets = fire_pulse(get_global_position(), 8, 0, style);
			for b in bullets:
				b.init_minimal_bullet(style);
				b.set_linear_velocity(b.dir*300);
		1:
			pass
		_:
			pass

func init_pixel_bullets():
	pass

func init_3d_bullets():
	pass

func init_collage_bullets():
	pass

func fire_pulse(pos, num, offset, style):
	var degrees = offset;
	var degree_inc = 360.0/num;
	var bullets = [];
	for i in num:
		var b = basic_bullet.instance();
		var radians = degrees*PI/180;
		degrees += degree_inc;
		b.dir = Vector2(cos(radians), sin(radians));
		b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
		b.set_global_position(get_global_position());
		get_parent().add_child(b)
		bullets.append(b);
	return bullets;

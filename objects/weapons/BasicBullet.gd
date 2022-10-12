extends RigidBody2D

var style = Global.initial_style
var basic_bullet = load("res://objects/weapons/BasicBullet.tscn");
var dir = Vector2();
var damage = 0.0;


func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	dir = _dir;
	set_bullet_rotation(_dir);
	style = _style;
	init_style(_style);

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Player" in body.name:
		body.damage(10)
		
		queue_free()

func show_verse_style(verse):
	get_node("Style%d" % style).show()
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()

func _on_Verse_Jump(verse):
	style = verse
	show_verse_style(verse);

func init_style(_style):
	style = _style;
	show_verse_style(_style);
	match _style:
		0:
			init_minimal_bullet();
		1:
			init_pixel_bullet();
		2:
			init_3d_bullet();
		3:
			init_collage_bullet();
		_:
			pass

# initialize the properties of these bullets
# minimal bullets have no real unique properties
func init_minimal_bullet():
	# ie.) init bullet properties
	damage = 1.0;

func init_pixel_bullet():
	pass

func init_3d_bullet():
	pass

func init_collage_bullet():
	pass
	
func set_bullet_rotation(_dir):
	rotation = 2*PI + atan2(_dir.y, _dir.x);

func fire_pulse(num, offset, style):
	var degrees = offset;
	var degree_inc = 360.0/num;
	for i in num:
		var b = basic_bullet.instance();
		var radians = degrees*PI/180;
		b.dir = Vector2(cos(radians), sin(radians));
		# b.bouncing = bouncing;
		# b.num_bounces = num_bounces;
		pass

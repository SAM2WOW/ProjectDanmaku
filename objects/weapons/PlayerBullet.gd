extends RigidBody2D

var style = Global.initial_style
var damage = 10;
var dir = Vector2();
var bullet = load("res://objects/weapons/PlayerBullet.tscn");
var bullet_properties = Global.player_bullet_properties[style];
var explosion = preload("res://objects/weapons/PlayerExplosion.tscn");
var curr_vel = 0.0;

func _ready():
	pass;

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Bullet Collide %s" % body.name)
	if "Boss" in body.name:
		# spawns an explosion at collision area if pixel bullet
		if (style==1):
			var e = explosion.instance();
			e.get_node("AnimatedSprite").play();
			get_tree().root.add_child(e);
			e.set_global_position(get_global_position());
			e.damage = damage;
		else:
			body.damage(damage)
		
		queue_free()

func show_verse_style(verse):
	# show all the styles
	get_node("Style%d" % verse).show()
	# hide the styles that aren't said style
	for i in range(Global.total_style):
		if i != verse:
			get_node("Style%d" % i).hide()

# determines how it moves and appearance
func init_pixel_bullet(pos, verse):
	set_global_position(pos);
	damage = bullet_properties["damage"];
	show_verse_style(verse);
	style = verse;
	add_force(Vector2.ZERO, dir*bullet_properties["speed"]);

func init_normal_bullet(pos, style):
	set_global_position(pos);
	damage = bullet_properties["damage"];
	show_verse_style(style);
	set_linear_velocity(dir*bullet_properties["speed"]);

func init_minimal_verse():
	pass
	
func explode():
	pass

# verse enter function
func _on_Verse_Jump(verse):
	Global.prev_style = style
	style = verse
	show_verse_style(style)
	damage = Global.player_bullet_properties[style].damage;

	match style:
		1:
			pass
		_:
			pass

# verse exit function
func _on_Verse_Exit(prev_verse, new_verse):
	match prev_verse:
		1:
			var new_dmg =  Global.player_bullet_properties[new_verse].damage;
			fire_spread(get_position(), new_verse, 3, 10, new_dmg/2, curr_vel);
			queue_free();
		_:
			pass
	pass

func fire_spread(pos, style, num, deg, damage, speed):
	var new_dir = Vector2();
	var new_deg = 0.0;
	var odd = (num%2 != 0);
	for i in num:
		var b = bullet.instance();
		# b._on_Verse_Jump(style)
		b.show_verse_style(style);
		get_parent().add_child(b)
		b.set_global_position(pos);
		b.damage = damage;
		
		if (!odd):
			new_deg = ((deg*1.5)+(i*deg))-(deg*(num-1));
		else:
			new_deg = (deg*(int(num/2))-(i*deg));
		new_deg *= PI/180;
		new_dir = Vector2(
			dir.x * (cos(new_deg)) + dir.y * (sin(new_deg)),
			dir.y * (cos(new_deg)) - dir.x * (sin(new_deg))
		);
		b.dir = new_dir;
		# print("fire bullet at %d" % new_deg);
		b.set_linear_velocity(new_dir*speed);
		b.rotation = 2*PI + atan2(new_dir.y, new_dir.x);

func _physics_process(delta):
	curr_vel = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2));

# bursts after 1/2 way to dest perhaps
func pixel_verse_properties():
	pass;


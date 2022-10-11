extends RigidBody2D

var style = Global.initial_style
var damage = 10;
var dir = Vector2();
var bullet = load("res://objects/weapons/PlayerBullet.tscn");
var explosion = preload("res://objects/weapons/PlayerExplosion.tscn");
var curr_vel = 0.0;
var num_bounces = 2;

func _ready():
	pass;

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass


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
	style = verse;
	get_node("Style%d" % verse).show()
	# hide the styles that aren't said style
	for i in range(Global.total_style):
		if i != verse:
			get_node("Style%d" % i).hide()

# determines how it moves and appearance
func init_pixel_bullet(pos, verse):
	set_global_position(pos);
	damage = Global.player_bullet_properties[style]["damage"];
	show_verse_style(verse);
	style = verse;
	add_force(Vector2.ZERO, dir*Global.player_bullet_properties[style]["speed"]);

func init_normal_bullet(pos, style):
	set_global_position(pos);
	damage = Global.player_bullet_properties[style]["damage"];
	show_verse_style(style);
	set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);

func init_3d_bullet(pos, style, charge):
	set_global_position(pos)
	damage = Global.player_bullet_properties[style]["damage"] * charge;
	if charge >= 1:
		damage *= 1.5;
	show_verse_style(style)
	set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"])

func init_minimal_bullet(pos, style):
	set_global_position(pos);
	damage = Global.player_bullet_properties[style]["damage"];
	show_verse_style(style);
	set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);
	
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
		0:
			pass
		1:
			var new_dmg =  Global.player_bullet_properties[new_verse].damage;
			fire_spread(get_global_position(), new_verse, 3, 20, new_dmg/2, curr_vel);
			queue_free();
		2:
			pass
		3:
			pass
		_:
			pass
	pass
	
func bounce_bullet():
	if (get_global_position().y < -Global.window_height/2 || get_global_position().y >= Global.window_height/2):
		dir = Vector2(dir.x, -dir.y);
		set_linear_velocity(dir*curr_vel);
		num_bounces-=1;
	if (get_global_position().x < -Global.window_width/2 || get_global_position().x >= Global.window_width/2):
		dir = Vector2(-dir.x, dir.y);
		set_linear_velocity(dir*curr_vel);
		num_bounces-=1;

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
	if (style == 3 && num_bounces > 0):
		bounce_bullet();

# bursts after 1/2 way to dest perhaps
func pixel_verse_properties():
	pass;


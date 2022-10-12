extends RigidBody2D

var prev_style = Global.initial_style;
var style = Global.initial_style
var damage = 10;
var dir = Vector2();
var bullet = load("res://objects/weapons/PlayerBullet.tscn");
var explosion = preload("res://objects/weapons/PlayerExplosion.tscn");
var curr_vel = 0.0;
var num_bounces = 0;
var bouncing = false;
var charge = 0.0;
var can_explode = false;

var init_dist = Vector2();
var dest = Vector2.ZERO;

func _ready():
	pass;

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass


func _on_PlayerBullet_body_entered(body):
	print("Bullet Collide %s" % body.name)
	if "Boss" in body.name:
		# spawns an explosion at collision area if pixel bullet
		if (can_explode):
			explode();
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

func init_normal_bullet(pos, verse):
	set_global_position(pos);
	show_verse_style(verse);
	damage = Global.player_bullet_properties[verse]["damage"];
	set_linear_velocity(dir*Global.player_bullet_properties[verse]["speed"]);

# determines how it moves and appearance
func init_pixel_bullet(pos, verse, _dest):
	set_global_position(pos);
	show_verse_style(verse);
	dest = _dest;
	init_dist =	sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));
	damage = Global.player_bullet_properties[verse]["damage"];
	can_explode = true;
	set_linear_velocity(dir*Global.player_bullet_properties[verse]["speed"]);

func init_3d_bullet(pos, verse, _charge):
	set_global_position(pos)
	show_verse_style(verse)
	charge = _charge;
	damage = Global.player_bullet_properties[verse]["damage"] * charge;
	if charge >= 1:
		damage *= 1.5;
	set_linear_velocity(dir*Global.player_bullet_properties[verse]["speed"])

func init_minimal_bullet(pos, verse):
	set_global_position(pos);
	show_verse_style(verse);
	damage = Global.player_bullet_properties[verse]["damage"];
	set_linear_velocity(dir*Global.player_bullet_properties[verse]["speed"]);

func init_collage_bullet(pos, verse):
	damage = Global.player_bullet_properties[verse]["damage"];
	var bullets = fire_spread(pos, verse, 3, 30, damage, Global.player_bullet_properties[verse]["speed"]);
	for b in bullets:
		b.bouncing = true;
		b.num_bounces = 2;
	queue_free();
	
func explode():
	var e = explosion.instance();
	e.get_node("AnimatedSprite").play();
	get_tree().root.add_child(e);
	e.set_global_position(get_global_position());
	e.damage = damage;

# verse enter function
func _on_Verse_Jump(verse):
	Global.prev_style = style
	prev_style = style;
	style = verse
	show_verse_style(style)
	damage = Global.player_bullet_properties[style].damage * (1+charge);

	match style:
		# on entering minimal
		0:
			pass
		# on entering pixel
		1:
			pass
		2:
			# bullet gets a bit more charged if it enters and slower
			if (charge == 0.0): 
				charge = 0.4;
			else: 
				charge *= 1.5;
			if (charge > 1.0): charge = 1.0
			damage *= charge + 1;
			linear_velocity *= (1-(charge/2));
		3:
			if (!bouncing):
				bouncing = true;
				num_bounces = 2;
		_:
			pass

# verse exit function
func _on_Verse_Exit(prev_verse, new_verse):
	match prev_verse:
		0:
			# on exiting 0, bullets get weaker but go faster
			damage = Global.player_bullet_properties[new_verse].damage*0.75;
			set_linear_velocity(get_linear_velocity()*1.2);
		1:
			# on exiting pixel, bullet splits into 3
			var new_dmg = Global.player_bullet_properties[new_verse].damage;
			var speed = curr_vel;
			if (new_verse == 2): 
				damage = 50;
				new_dmg = damage*charge;
				speed *= (1-(charge/2));
			fire_spread(get_global_position(), new_verse, 3, 20, new_dmg/2, speed);
			queue_free();
		2:
			# on exiting 2, damage of bullet scales with charge upwards
			damage = Global.player_bullet_properties[new_verse].damage * (charge+1);
		3:
			# on exiting, can bounce twice if it cant bounce already
			if (!bouncing):
				bouncing = true;
				num_bounces = 2;
		_:
			pass
	
func bounce_bullet():
	if (get_global_position().y < -Global.window_height/2 || get_global_position().y >= Global.window_height/2):
		dir = Vector2(dir.x, -dir.y);
		set_linear_velocity(dir*curr_vel);
		rotation = 2*PI + atan2(dir.y, dir.x);
		num_bounces-=1;
	if (get_global_position().x < -Global.window_width/2 || get_global_position().x >= Global.window_width/2):
		dir = Vector2(-dir.x, dir.y);
		set_linear_velocity(dir*curr_vel);
		rotation = 2*PI + atan2(dir.y, dir.x);
		num_bounces-=1;

func fire_spread(pos, style, num, deg, damage, speed):
	var new_dir = Vector2();
	var new_deg = 0.0;
	var odd = (num%2 != 0);
	var bullets = [];
	for i in num:
		var b = bullet.instance();
		# b._on_Verse_Jump(style)
		b.charge = charge;
		b.bouncing = bouncing;
		b.num_bounces = num_bounces;
		# b.can_explode = can_explode;
		b.show_verse_style(style);
		get_parent().add_child(b)
		b.set_global_position(pos);
		
		# if charged, scale the bullet damage
		b.damage = damage * (charge+1);
		
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
		bullets.append(b);
	return bullets;
	
func _physics_process(delta):
	curr_vel = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2));
	# if (style == 2):
		# scale = Vector2(1+charge, 1+charge);
	if (charge > 0):
		scale = Vector2(1+charge, 1+charge);
	if (style == 1 && dest != Vector2.ZERO):
		var pos = get_global_position();
		var dest_dist = sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));
		var dest_ratio = dest_dist/init_dist;
		var speed = Global.player_bullet_properties[style]["speed"];
		var base_speed = 100;
		linear_velocity = Vector2(dir.x*(base_speed+speed*dest_ratio), dir.y*(base_speed+speed*dest_ratio));
		if (dest_ratio < 0.01):
			explode();
			queue_free();
	if (bouncing && num_bounces > 0):
		bounce_bullet();

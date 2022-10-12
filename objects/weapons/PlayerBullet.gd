extends RigidBody2D

var style = Global.initial_style
var damage = 10;
var dir = Vector2();
var bullet = load("res://objects/weapons/PlayerBullet.tscn");

# detonate variables
var detonate = false;
var detonate_at_pos = false;
var detonate_pos = Vector2();
var detonate_init_dist = 0.0;
var explosion = preload("res://objects/weapons/PlayerExplosion.tscn");

var curr_vel = 0.0;
var num_bounces = 0;
var bouncing = false;
var charge = 0.0;

var init_dist = Vector2();
var dest = Vector2.ZERO;


func _ready():
	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	pass


func _on_PlayerBullet_body_entered(body):
	print("Bullet Collide %s" % body.name)
	if "Boss" in body.name:
		# spawns an explosion at collision area if pixel bullet
		if (detonate):
			explode();
		else:
			body.damage(damage)
		
		queue_free()

# show the bullet style
func show_verse_style(verse):
	get_node("Style%d" % style).hide()
	
	style = verse
	
	get_node("Style%d" % style).show()
	
	$TransEffect.restart()
	$TransEffect.set_emitting(true)

	var tween = create_tween()
	if tween:
		get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
		tween.set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	

# set the position, dir, rotation, and style
func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	dir = _dir;
	set_bullet_rotation(_dir);
	style = _style;
	init_style(_style);

func init_style(_style):
	style = _style;
	show_verse_style(_style);
	match _style:
		0:
			init_minimal_bullet();
		1:
			pass
			# init_pixel_bullet();
		2:
			pass
			# init_3d_bullet();
		3:
			pass
			# init_collage_bullet();
		_:
			pass

# init bullet types
func init_pixel_bullet():
	damage = Global.player_bullet_properties[style]["damage"];
	
func set_detonate(dest=get_global_mouse_position()):
	var pos = get_global_position();
	detonate = true;
	detonate_at_pos = true;
	detonate_pos = dest;
	detonate_init_dist =	sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));

func init_3d_bullet():
	charge = 0.5;
	damage = Global.player_bullet_properties[style]["damage"] * charge;
	if charge >= 1:
		damage *= 1.5;

func init_minimal_bullet():
	damage = Global.player_bullet_properties[style]["damage"];

func init_collage_bullet():
	damage = Global.player_bullet_properties[style]["damage"];
	bouncing = true;
	num_bounces = 2;

func explode():
	var e = explosion.instance();
	e.get_node("AnimatedSprite").play();
	get_tree().root.add_child(e);
	e.set_global_position(get_global_position());
	e.damage = damage;

# verse enter function
func _on_Verse_Jump(verse):
	style = verse
	show_verse_style(style)
	# damage = Global.player_bullet_properties[style].damage * (1+charge);

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
func _on_Verse_Exit(verse):
	match verse:
		0:
			# on exiting 0, bullets get weaker but go faster
			damage = Global.player_bullet_properties[verse].damage*0.75;
			set_linear_velocity(get_linear_velocity()*1.2);
		1:
			# on exiting pixel, bullet splits into 3
			var new_dmg = Global.player_bullet_properties[verse].damage;
			var speed = curr_vel;
			if (verse == 2): 
				damage = 50;
				new_dmg = damage*charge;
				speed *= (1-(charge/2));
			Global.player.fire_spread(3, 20, speed, dir, get_global_position());
			queue_free();
		2:
			# on exiting 2, damage of bullet scales with charge upwards
			damage = Global.player_bullet_properties[verse].damage * (charge+1);
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

func set_bullet_rotation(_dir):
	rotation = 2*PI + atan2(_dir.y, _dir.x);

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
			new_deg = (i-(num*0.5)+0.5)*deg;
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
	# dir = Vector2.UP.rotated(get_rotation());
	dir = linear_velocity.normalized();
	# if (style == 2):
		# scale = Vector2(1+charge, 1+charge);

	if (charge > 0):
		scale = Vector2(1+charge, 1+charge);
	if (detonate_at_pos):
		var speed = Global.player_bullet_properties[style]["speed"]; var base_speed = 100; var pos = get_global_position();
		
		var detonate_dist = sqrt(pow(detonate_pos.x-pos.x,2)+pow(detonate_pos.y-pos.y,2));
		var dist_ratio = detonate_dist/detonate_init_dist;
		set_linear_velocity(Vector2(
			dir.x*(base_speed+speed*dist_ratio), 
			dir.y*(base_speed+speed*dist_ratio)
		));
		if (dist_ratio < 0.01):
			explode();
			queue_free();
	if (bouncing && num_bounces > 0):
		bounce_bullet();

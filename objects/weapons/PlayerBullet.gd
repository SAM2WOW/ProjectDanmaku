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

var dying = false

func _ready():
	pass


func _on_VisibilityNotifier2D_screen_exited():
	if get_node("CollisionShape2D").disabled == false:
		dying = true
		queue_free()


func _on_PlayerBullet_body_entered(body):
	#print("Bullet Collide %s" % body.name)
	if "Boss" in body.name:
		# spawns an explosion at collision area if pixel bullet
		if (detonate):
			explode();
		else:
			if (style == 2):
				damage *= charge;
				# minimum damage
				if (damage < 5.0): damage = 5.0;
				if (charge >= 1.0):
					damage *= 1.25;
			else:
				charge *= 0.75;
				damage *= (1+charge);
			body.damage(damage,self)
	dying = true
	queue_free()

func _on_destroy():
	if (detonate):
		explode();
		
	dying = true
	queue_free()
		
# show the bullet style
func show_verse_style(verse):
	get_node("Style%d" % style).show()
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
	
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
			init_pixel_bullet();
		2:
			init_3d_bullet();
		3:
			init_collage_bullet();
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
	detonate_init_dist = sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));
	if (detonate_init_dist <= 10):
		explode();
		dying = true;
		queue_free();

func init_3d_bullet():
	damage = Global.player_bullet_properties[style]["damage"];

func init_minimal_bullet():
	damage = Global.player_bullet_properties[style]["damage"];

func init_collage_bullet():
	damage = Global.player_bullet_properties[style]["damage"];
	bouncing = true;
	num_bounces = 2;

func explode():
	var e = explosion.instance();
	e.get_node("AnimatedSprite").play();
	e.charge = charge;
	get_tree().root.add_child(e);
	e.set_global_position(get_global_position());
	e.damage = damage;

# verse enter function
func _on_Verse_Jump(verse):
	style = verse
	show_verse_style(verse)
	damage = Global.player_bullet_properties[verse]["damage"];
	
	match verse:
		# on entering minimal, goes faster
		0:
			linear_velocity *= 1.2;
		# on entering pixel, goes slower and can explode
		1:
			linear_velocity *= 0.8;
			detonate = true;
		# on entering 3d, gets charged
		2:
			# if uncharged on entering, gets a charge of 0.5
			if (charge <= 0.0): charge += 0.2;
			charge += 0.5;
			if (charge > 1.0): charge = 1.0
			linear_velocity *= (1-(charge/2));
		# on entering collage, bullets get faster and can bounce
		3:
			linear_velocity *= 1.2;
			if (!bouncing):
				bouncing = true;
				num_bounces = 2;
		_:
			pass

# verse exit function
func _on_Verse_Exit(prev_verse, new_verse):
	# damage = Global.player_bullet_properties[new_verse]["damage"];
	match prev_verse:
		# on exiting minimal, bullets go faster but a lot weaker
		0:
			damage *= 0.6;
			linear_velocity *= 1.2;
		# on exiting pixel, bullet splits into 3
		1:
			var bullets = Global.player.fire_spread(3, 15, curr_vel, dir, 1, get_global_position(), new_verse);
			for b in bullets:
				b.damage = damage;
				b.charge = charge;
				b.damage *= 0.6;
				b.linear_velocity *= (1-(charge*0.6));
				if (bouncing): b.num_bounces = num_bounces;
			queue_free();
		2:
			# on exiting 2, damage of bullet scales with charge upwards
			pass;
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
	
func _physics_process(delta):
	curr_vel = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2));
	# dir = Vector2.UP.rotated(get_rotation());
	dir = linear_velocity.normalized();
	# minimum speed
	var min_speed = 100;
	if (curr_vel < min_speed):
		set_linear_velocity(min_speed*dir);
	if (charge > 0.0):
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
			dying = true
			queue_free();
	if (bouncing && num_bounces > 0):
		bounce_bullet();


func _on_DespawnTimer_timeout():
	dying = true
	queue_free();

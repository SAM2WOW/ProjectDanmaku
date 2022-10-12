extends RigidBody2D

var style = Global.initial_style
var basic_bullet = load("res://objects/weapons/BasicBullet.tscn");
var dir = Vector2();
var curr_vel = 0.0;

# for detonation bullets
var detonate = false;
var detonate_at_pos = false;
var detonate_init_dist = Vector2.ZERO;
var detonate_pos = Vector2.ZERO;
var explosion = preload("res://objects/weapons/EnemyExplosion.tscn");
var detonate_at_speed = false;

# for bouncing bullets
var bouncing = false;
var num_bounces = 0;

var damage = 1.0;

func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	dir = _dir;
	set_bullet_rotation(_dir);
	style = _style;
	init_style(_style);

func init_clone_instance(b):
	b.bouncing = bouncing;
	b.num_bounces = num_bounces;
	b.detonate = detonate;
	b.get_node("DespawnTimer").start($DespawnTimer.time_left);

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Player" in body.name:
		if detonate:
			explode();
		else:
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
	match verse:
		# into minimal; bullets get faster
		0:
			linear_velocity *= 1.2;
		# into pixel; bullets go slower
		1:
			linear_velocity *= 0.8;
		# into 3d; laser gets charged
		2:
			pass
		# into collage; bullets can bounce and gets slower
		3:
			linear_velocity *= 0.7;
			if !bouncing:
				bouncing = true;
				num_bounces = 1;
		_:
			pass
	
func _on_Verse_Exit(verse):
	match verse:
		# on leaving minimal verse, nothing
		0:
			pass
		# on leaving pixel verse, splits into 2
		1:
			var bullets = Global.boss.fire_spread(2, 20, curr_vel*0.8, dir, get_global_position());
			for b in bullets:
				init_clone_instance(b);
			queue_free();
		# on leaving 3d verse, bullets increase in size? and are slower?
		2:
			pass
		# on leaving collage verse, can bounce once and are slower
		3:
			if !bouncing:
				linear_velocity *= 0.7;
				bouncing = true;
				num_bounces = 1;
		_:
			pass

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
	bouncing = true;
	num_bounces = 1;
	
func set_bullet_rotation(_dir):
	rotation = 2*PI + atan2(_dir.y, _dir.x);
	
func set_detonate(dest=Global.player.get_global_position()):
	var pos = get_global_position();
	detonate = true;
	detonate_at_pos = true;
	detonate_pos = dest;
	detonate_init_dist =	sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));

func explode():
	var e = explosion.instance();
	e.get_node("AnimatedSprite").play();
	get_parent().add_child(e);
	e.set_global_position(get_global_position());
	e.damage = damage;

func bounce_bullet():
	var bounce = false;
	if (get_global_position().y < -Global.window_height/2 || get_global_position().y >= Global.window_height/2):
		dir = Vector2(dir.x, -dir.y);
		bounce = true;
	if (get_global_position().x < -Global.window_width/2 || get_global_position().x >= Global.window_width/2):
		dir = Vector2(-dir.x, dir.y);
		bounce = true;
	if bounce:
		set_linear_velocity(dir*curr_vel);
		rotation = 2*PI + atan2(dir.y, dir.x);
		num_bounces-=1;
	
func _physics_process(delta):
	curr_vel = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2));
	if (detonate_at_pos):
		var speed = 1000; var base_speed = 100; var pos = get_global_position();
		
		var detonate_dist = sqrt(pow(detonate_pos.x-pos.x,2)+pow(detonate_pos.y-pos.y,2));
		var dist_ratio = detonate_dist/detonate_init_dist;
		set_linear_velocity(Vector2(
			dir.x*(base_speed+speed*dist_ratio), 
			dir.y*(base_speed+speed*dist_ratio)
		));
		if (dist_ratio < 0.01):
			explode();
			queue_free();
	elif (detonate_at_speed):
		if (curr_vel < 100):
			explode();
			queue_free();
		else:
			linear_velocity *= 0.95;
	
	if (bouncing && num_bounces > 0):
		bounce_bullet();


func _on_DespawnTimer_timeout():
	print("bullet despawned")
	queue_free();

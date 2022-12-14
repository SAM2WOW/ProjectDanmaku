extends RigidBody2D

var style = Global.initial_style
var basic_bullet = load("res://objects/weapons/BasicBullet.tscn");
var dir = Vector2();
var curr_vel = 0.0;

var jumped = false;

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

var dying
var damage = 0.0;


func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	dir = _dir;
	set_bullet_rotation(_dir);
	style = _style;
	init_style(_style);

func init_clone_instance(b):
	b.damage = damage;
	b.bouncing = bouncing;
	b.num_bounces = num_bounces;
	b.detonate = detonate;
	b.get_node("DespawnTimer").start($DespawnTimer.time_left);

func _on_VisibilityNotifier2D_screen_exited():
	dying = true
	queue_free()

func _on_PlayerBullet_body_entered(body):
	#print("Collide %s" % body.name)
	if "Player" in body.name:
		if detonate:
			explode();
		else:
			body.damage(Global.boss_bullet_properties[Global.difficulty][style]["damage"]);
	dying = true
	queue_free()

func show_verse_style(verse):
	#print('changing to %d' % style)
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


# enters first
func _on_Verse_Jump(verse):
	style = verse;
	show_verse_style(verse);
	#print(verse)
	match verse:
		# into minimal; bullets get faster
		0:
			linear_velocity *= 1.2;
		# into pixel; bullets go slower and blow at speed
		1:
			if (!detonate):
				detonate = true;
			# if main verse is now pixel, detonate at speed
			if (Global.new_style == verse):
				detonate_at_speed = true;
				
		# into 3d; laser gets charged
		2:
			if (!is_instance_valid(Global.boss)): return;
			Global.boss.fireLaser(get_global_position(), get_global_position() + (dir * 50), true, false)
			dying = true
			queue_free()
		# into collage; bullets can bounce and gets slower
		3:
			linear_velocity *= 1.2;
			if !bouncing:
				bouncing = true;
				num_bounces = 1;
		_:
			pass
	
func _on_Verse_Exit(prev_verse, new_verse):
	#print("exiting %d and entering %d" % [prev_verse, new_verse])
	match prev_verse:
		# on leaving minimal verse, nothing
		0:
			pass;
		# on leaving pixel verse, splits into 2
		1:
			detonate = false;
			detonate_at_pos = false;
			detonate_at_speed = false;
			
			# why not 3d verse??
			if (new_verse != 2):
				var bullets = Global.boss.fire_spread(2, 20, Global.boss_bullet_properties[Global.difficulty][new_verse]["speed"]*0.8, dir, get_global_position(), new_verse);
				for b in bullets:
					init_clone_instance(b);
			dying = true
			queue_free();
		# on leaving 3d verse, bullets are a lot faster and weaker
		2:
			damage *= 0.7;
			linear_velocity *= 1.4;
		# on leaving collage verse, can bounce once and are slower
		3:
			if !bouncing:
				linear_velocity *= 0.7;
				init_collage_bullet();
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
	damage = Global.boss_bullet_properties[Global.difficulty][style]["damage"];
	style = 0;

func init_pixel_bullet():
	damage = Global.boss_bullet_properties[Global.difficulty][style]["damage"];
	style = 1;

func init_3d_bullet():
	damage = Global.boss_bullet_properties[Global.difficulty][style]["damage"];
	style = 2;

func init_collage_bullet():
	damage = Global.boss_bullet_properties[Global.difficulty][style]["damage"];
	bouncing = true;
	num_bounces = 1;
	style = 3;
	
func set_bullet_rotation(_dir):
	rotation = 2*PI + atan2(_dir.y, _dir.x);
	
func set_detonate(dest=Global.player.get_global_position()):
	var pos = get_global_position();
	detonate = true;
	detonate_at_pos = true;
	detonate_pos = dest;
	detonate_init_dist = sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));
	if (detonate_init_dist <= 10):
		explode();
		dying = true;
		queue_free();

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
		var speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];
		var base_speed = 100; 
		var pos = get_global_position();
		
		var detonate_dist = sqrt(pow(detonate_pos.x-pos.x,2)+pow(detonate_pos.y-pos.y,2));
		var dist_ratio = detonate_dist/detonate_init_dist;
		if (curr_vel >= (speed+base_speed)*1.5):
			explode();
			dying = true;
			queue_free();
			return;
		set_linear_velocity(Vector2(
			dir.x*(base_speed+speed*dist_ratio), 
			dir.y*(base_speed+speed*dist_ratio)
		));
		if (dist_ratio < 0.01):
			explode();
			dying = true
			queue_free();
			return;
	# for some reason is verse jumping when this happens?????
	if (detonate_at_speed):
		var base_speed = 75.0;
		linear_velocity *= 0.99;
		if (curr_vel <= base_speed):
			detonate_at_speed = false;
			explode();
			dying = true
			queue_free();
			return;

	
	if (bouncing && num_bounces > 0):
		bounce_bullet();


func _on_DespawnTimer_timeout():
	#print("bullet despawned")
	dying = true
	queue_free();

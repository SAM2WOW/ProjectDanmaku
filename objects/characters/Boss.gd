extends KinematicBody2D

var style = Global.initial_style
var style_pool = [0, 2, 3]
var prev_style = style;
var hit_by = []
var attack_pattern = 0;
var fire_rate = 1;
var rng = RandomNumberGenerator.new();
var enraged = false;
var dead = false;

var stats = Global.boss_stats[Global.difficulty];
# boss statsv
var max_hp = stats["hp"]
var hp = max_hp;
var base_speed = stats["speed"];
var move_speed = base_speed;
var movement_interval = stats["movement interval"];
var attack_interval = stats["attack interval"];
var transbullet_max_cd = stats["trans bullet cd"];
var transbullet_cd = transbullet_max_cd
var missed_bullet_counter = 0
var max_missed_bullets = stats["missed bullet cd"];
var stun_timer = 0.0;
var stun_dur = stats["stun duration"];
# movement
var move_to_pos = Vector2();
var move_to_dir = Vector2();
var pos_offset = 200;
var dist_offset = 200;
var dest_offset = 10;
var moving = false;

# for moving to the center
var move_to_center = false;
var init_dist_to_center = Vector2();
var duel_bullet;
var stunned = false

var transbullet_state = false
var break_state = false
var last_trans_bullet = null


var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")
var damage_text = preload("res://objects/system/DamageText.tscn")
var laserInd = preload("res://objects/weapons/LaserIndicator.tscn")
var laserBeam = preload("res://objects/weapons/LaserBeam.tscn")

var attack_properties;
var curr_damage_text;


func _ready():
	Global.boss = self;
	init_boss_stats();
	_on_Verse_Jump(Global.initial_style);
	attack_pattern = rng.randi()%2;
	
	style_pool.shuffle()
	style_pool.append(1)

func init_boss_stats():
	var stats = Global.boss_stats[Global.difficulty];
	# boss statsv
	max_hp = stats["hp"]
	hp = max_hp;
	base_speed = stats["speed"];
	move_speed = base_speed;
	movement_interval = stats["movement interval"];
	attack_interval = stats["attack interval"];
	transbullet_max_cd = stats["trans bullet cd"];
	transbullet_cd = transbullet_max_cd
	missed_bullet_counter = 0
	max_missed_bullets = stats["missed bullet cd"];
	stun_timer = 0.0;
	stun_dur = stats["stun duration"];

func _process(delta):
	# hp = Global.console.boss_health;
	var sprite = get_node("Style%d/AnimatedSprite"%style);
	if (dead && is_instance_valid(sprite)):
		modulate = Color("#8a8a8a");
		sprite.stop();
	if (hp <= max_hp*0.5 && !enraged):
		enrage_boss();
	if (enraged && !stunned && is_instance_valid(sprite)):
		sprite.speed_scale = 2.0;
	if stunned:
		update_stun(delta);
	
func _physics_process(delta):
	if moving && !dead:
		if (move_to_center):
			move_to_center();
		else:
			move_to_random_pos();

func enrage_boss():
	print("enraged!");
	movement_interval *= 0.7;
	transbullet_max_cd -= 1;
	base_speed += 150;
	enraged = true;
	attack_interval *= 0.7;
	max_missed_bullets -= 1;
	for style in Global.boss_patterns[Global.difficulty]:
		for pattern in Global.boss_patterns[Global.difficulty][style]:
			Global.boss_patterns[Global.difficulty][style]["waves"] += 1;
			Global.boss_patterns[Global.difficulty][style]["interval"] *= 0.8;

func update_stun(delta):
	var sprite = get_node("Style%d/AnimatedSprite"%style);
	if (is_instance_valid(sprite) && Global.new_style == Global.current_style):
		sprite.stop();
	modulate = Color("#8a8a8a");
	stun_timer += delta;
	$FireTimer.stop();
	$MovementTimer.stop();
	moving = false;
	if (stun_timer >= stun_dur):
		if (is_instance_valid(sprite)):
			sprite.play();
			sprite.speed_scale = 1;
		modulate = Color("ffffff");
		stunned = false;
		print("no longer stunned")
		start_move_to_random_pos();
		rng.randomize();
		attack_pattern = rng.randi()%2;
		$FireTimer.start(attack_interval);
		stun_timer = 0.0;

func damage(amount,body = null):
	# print("Boss have been damaged %d" % amount)
	var stun_mult = 1.0;
	if (stunned): stun_mult = 1.5;
	# Global.console.damage_boss(amount*stun_mult)
	if Global.console.gameover == false:
		hp -= amount*stun_mult;
		Global.console.set_healthbar(hp);
		if hp <= 0:
			Global.console.boss_dead()
	
	# effects
	var tween1 = create_tween().set_trans(Tween.TRANS_CUBIC)
	#var tween2 = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween1.tween_property(self, "modulate", Color("#f76b60"), 0.08)
	#tween2.tween_property($HealthBar, "rect_scale", Vector2(1.5,1.5), 0.08)
	tween1.set_trans(Tween.TRANS_LINEAR)
	#tween1.tween_property($HealthBar, "scale", Vector2(1,1), 0.12)
	tween1.tween_property(self, "modulate", Color("ffffff"), 0.12)
	
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	
	get_node("Style%d/HitSound" % style).play()
	
	# Global.camera.shake(0.2, 10, 10);
	if not is_instance_valid(curr_damage_text):
		var t = damage_text.instance();
		curr_damage_text = t;
		t.set_global_position(get_global_position());
		t.amount = amount*stun_mult;
		yield(get_tree().create_timer(0.1), "timeout");
		# wait 0.1 seconds to see if anymore damage is taken
		if (t.amount >= 200 || stunned):
			t.type = "critical";
		get_parent().add_child(t)
		curr_damage_text = null;
	else:
		curr_damage_text.amount += amount*stun_mult;

func _on_Verse_Jump(verse):
	if ($MovementTimer.is_stopped()):
		$MovementTimer.start(movement_interval);
	
	style = verse
	print("BOSS STYLE: %d" % verse)
	
	get_node("Style%d" % style).show()
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
	
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	
	get_node("Style%d/TransEffect" % style).restart()
	get_node("Style%d/TransEffect" % style).set_emitting(true)


func fireLaser(fireFrom, fireAt, inPortal, bossSpawned=true):
	
	var ind = laserInd.instance();
	var timeBeforeBeam = 0.8
	var beamDuration = 0.5
	var particleDuration = 1
	
	get_parent().add_child(ind)
	ind.set_global_position(fireFrom)
	
	ind.add_point(Vector2.ZERO)
#	ind.add_point(get_global_position())
	# Makes sure laser always extends past viewport
	var dir = Vector2();
	# dir *= 10000;
	ind.add_point((fireAt - fireFrom) * 10000)
	
	yield(get_tree().create_timer(timeBeforeBeam), "timeout")
	
	var beam = laserBeam.instance();
	beam.set_global_position(fireFrom)
	beam.inPortal = inPortal;
	beam.bossSpawned = bossSpawned;
	get_parent().add_child(beam)
	var beamPoint = ind.points[1]
#	beamPoint[1] /= 5
	beam.set_cast_to(beamPoint)
	
	ind.queue_free()
	yield(get_tree().create_timer(beamDuration), "timeout")
	beam.is_casting = false
	
	yield(get_tree().create_timer(particleDuration), "timeout")
	beam.queue_free()

func finish_attack():
	if Global.console.gameover:
		return
		
	rng.randomize();
	attack_pattern = rng.randi()%2;
	$FireTimer.start(attack_interval);

	# firing portal bullet when the last trans bullet is freed
	if not is_instance_valid(last_trans_bullet):
		fire_trans_bullet();

func fire_trans_bullet():
	transbullet_cd -= 1
	print("trans bullet cd: ", transbullet_cd);
	# fire the transbullet
	if transbullet_cd <= 0:
		print("fire transbullet");
		var t = load("res://objects/weapons/TransBullet.tscn").instance()
		# style pesudo randomize
		randomize_transbullet(t);
		# reset transbullet cd
		transbullet_cd = transbullet_max_cd
		# fire duel mode bullet
		if (missed_bullet_counter >= max_missed_bullets):
			print('fire special bullet')
			missed_bullet_counter = 0;
			t.duel_mode = true;
			last_trans_bullet = t
			start_move_to_center();
		# increment missed bullet counter
		else:
			missed_bullet_counter += 1;
			print("missed bullets: ", missed_bullet_counter)
			get_parent().add_child(t);
			t.set_global_position(get_global_position());
		
		last_trans_bullet = t

func randomize_transbullet(t):
	# style pesudo randomize
	print("======= Current Style Pool" + str(style_pool))
	
	var new_style = style_pool[0]
	if new_style == Global.current_style:
		new_style = style_pool[1]
		style_pool.remove(1)
	else:
		style_pool.remove(0)
	
	style_pool.insert(2 + randi()%2, new_style)
	
	print("======= New Style Pool" + str(style_pool))
	t.style = new_style


func _on_FireTimer_timeout():
	fire_bullets();

func fire_bullets():
	attack_properties = Global.boss_patterns[Global.difficulty][style][attack_pattern];
	if enraged:
		attack_properties["waves"] += 1;
		attack_properties["interval"] *= 0.8;
		
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

# boss will have two attacks per style

# 0.) shoot like 4~ waves of minimal bullets around boss
# 1.) gatling 3~ waves of blobs of bullets towards the players position at fire
func init_minimal_bullets():
	match attack_pattern:
		0:
			var offset_inc = 10;
			var b_speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];

			for i in attack_properties["waves"]:
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				fire_pulse(8, b_speed, offset_inc*i);
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout");
			finish_attack();
		1:
			var num_bullets = 5;
			var b_speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];
			
			for i in attack_properties["waves"]:
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				var dir = get_global_position().direction_to(Global.player.get_global_position());
				fire_blob(num_bullets, b_speed, dir);
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout");
			finish_attack();
		_:
			pass

# 0: fire a wave of 4~ bullets towards the players position on firing, and blow them up when they reach there
# 1: fire bullets at random positions 7 times in quick successeon
func init_pixel_bullets():
	match attack_pattern:
		0:
			var b_speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];
			for i in attack_properties["waves"]:
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				var fire_pos = Global.player.get_global_position()
				var b = fire_at(fire_pos, b_speed);
				b.set_detonate(fire_pos);
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout");
			finish_attack();
		1:
			var b_speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];
			for i in attack_properties["waves"]:
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				rng.randomize();
				var rand_pos = Vector2(
					rng.randi_range(-Global.window_width/2, Global.window_width/2), 
					rng.randi_range(-Global.window_height/2, Global.window_height/2)
				);
				var b = fire_at(rand_pos, b_speed);
				b.set_detonate(rand_pos);
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout");
			finish_attack();
		_:
			pass

# 0: fires a wave of 4~ quick lasers towards the players position
# 1: shoot lasers in all directions, then rotate the lasers slowly around the boss (hades style)
func init_3d_bullets():
	match attack_pattern:
		0:
			var timeBetweenAttacks = 1.5
			var beamDuration = 0.5
			var maxX = get_viewport().size.x / 2
			var maxY = get_viewport().size.y / 2
			var xArr = [0, maxX, -maxX]
			var yArr = [0, maxY, -maxY]
			for x in xArr:
				for y in yArr:
					# Don't shoot a laser at (0,0)
					if (x!=0 || y!=0):
						fireLaser(get_global_position(), Vector2(x,y), false)
			yield(get_tree().create_timer(timeBetweenAttacks), "timeout")
			if (prev_style != style):
				prev_style = style;
				finish_attack();
				return;
			
			var xArr2 = [maxX, -maxX, maxX / 2, -maxX / 2]
			var yArr2 = [maxY, -maxY, maxY / 2, -maxY / 2]
			for x2 in xArr2:
				for y2 in yArr2:
					if (!(abs(x2) == maxX && abs(y2) == maxY) && !(abs(x2) == maxX/2 && abs(y2) == maxY/2)):
						fireLaser(get_global_position(), Vector2(x2,y2), false)
			yield(get_tree().create_timer(beamDuration), "timeout")
			finish_attack()
		1:
			for i in range(attack_properties["waves"]):
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				fireLaser(get_global_position(), Global.player.get_global_position(), false)
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout")
			finish_attack()
		_:
			pass

# 0: fire 2~ waves of shotgun shots of bouncing bullets towards the player
# 1: fire a singular circular shot
func init_collage_bullets():
	match attack_pattern:
		0:
			var dir = get_global_position().direction_to(Global.player.get_global_position());
			var b_speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];
			for i in attack_properties["waves"]:
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				fire_spread(3, 30, b_speed, dir);
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout");
			finish_attack();
		1:
			var b_speed = Global.boss_bullet_properties[Global.difficulty][style]["speed"];
			for i in attack_properties["waves"]:
				rng.randomize();
				var rand_offset = rng.randf_range(-20.0 , 20.0);
				fire_pulse(6, b_speed, rand_offset);
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout");
			finish_attack();
		_:
			pass

# fire one bullet at fire_pos
func fire_at(fire_pos, speed, pos=get_global_position(), _style=style):
	var b = basic_bullet.instance();
	var dir = pos.direction_to(fire_pos);
	
	b.init_bullet(pos, dir, _style);
	b.set_linear_velocity(dir*speed);
	
	get_parent().add_child(b);
	get_node("Style%d/FireSound" % _style).play()
	return b;

func fire_pulse(num, speed, offset=0.0, pos=get_global_position(), _style=style):
	var bullets = [];
	var degrees = 360.0/num;
	get_node("Style%d/FireSound" % _style).play()
	for i in num:
		var b = basic_bullet.instance();
		
		var radians = (offset+(i*degrees))*PI/180;
		var dir = Vector2(cos(radians), sin(radians));
		
		b.init_bullet(pos, dir, _style);
		b.set_linear_velocity(dir*speed);
		
		get_parent().add_child(b);
		bullets.append(b);
	return bullets;

func fire_circle(x,y,count = 24):
	var radius = 50.0
	var center = Vector2(x, y)
	# Get how much of an angle objects will be spaced around the circle.
	# Angles are in radians so 2.0*PI = 360 degrees
	var angle_step = 2.0*PI / count

	var angle = 0
	# For each node to spawn
	for i in range(0, count):

		var direction = Vector2(cos(angle), sin(angle))
		var pos = center + direction * radius
		var target_pos = center + direction * (radius+50)
		fire_at(target_pos,base_speed *2,pos)
		# Rotate one step
		angle += angle_step


func fire_spread(
	num, deg, speed, dir, pos=get_global_position(), _style=style
):
	var bullets = [];
	var odd = (num%2 != 0);
	for i in num:
		var b = basic_bullet.instance();
		var new_deg = 0.0;
		if !odd:
			new_deg = (i-(num*0.5)+0.5)*deg;
		else:
			new_deg = (deg*(int(num/2))-(i*deg));
		new_deg *= PI/180;
		
		var new_dir = Vector2(
			dir.x * (cos(new_deg)) + dir.y * (sin(new_deg)),
			dir.y * (cos(new_deg)) - dir.x * (sin(new_deg))
		);
		
		b.init_bullet(pos, new_dir, _style);
		b.set_linear_velocity(new_dir*speed);
		
		get_parent().add_child(b);
		bullets.append(b);
		get_node("Style%d/FireSound" % _style).play()
		get_node("Style%d/FireSound" % _style).play()
	return bullets;

# num bullets at the approximate position of the player
# dir and speed are randomized within a range (deg and pixel respectfully)
func fire_blob(num, speed, dir, degree_offset=30, speed_offset=100, _style=style, pos=get_global_position()):
	var bullets = [];
	for i in num:
		var b = basic_bullet.instance();
		
		rng.randomize();
		var new_deg = rng.randi_range(-degree_offset/2, degree_offset/2) * PI/180;
		var new_speed = rng.randi_range(-speed_offset/2, speed_offset/2) + speed;
		
		var new_dir = Vector2(
			dir.x * (cos(new_deg)) + dir.y * (sin(new_deg)),
			dir.y * (cos(new_deg)) - dir.x * (sin(new_deg))
		)
		
		b.init_bullet(pos, new_dir, _style);
		b.set_linear_velocity(new_dir*new_speed);
		
		get_parent().add_child(b);
		bullets.append(b);
		get_node("Style%d/FireSound" % _style).play()
	return bullets;


func _on_MovementTimer_timeout():
	start_move_to_random_pos();

func start_move_to_random_pos():
	var pos = get_global_position();
	move_speed = base_speed;
	var max_tries = 10;
	var rand_pos = Vector2();
	var pos_limit = Vector2(
		(Global.window_width-pos_offset)/2, 
		(Global.window_height-pos_offset)/2
	)
	rng.randomize();
	rand_pos = Vector2(
		rng.randi_range(-pos_limit.x, pos_limit.x), 
		rng.randi_range(-pos_limit.y, pos_limit.y)
	);
	while sqrt(pow(rand_pos.x-pos.x,2)+pow(rand_pos.y-pos.y,2)) < dist_offset:
		rng.randomize();
		rand_pos = Vector2(
			rng.randi_range(-pos_limit.x, pos_limit.x), 
			rng.randi_range(-pos_limit.y, pos_limit.y)
		);
		max_tries -= 1;
		if max_tries <= 0:
			print("failed too many tries")
			$MovementTimer.start(movement_interval);
			return;

	moving = true;
	move_to_pos = rand_pos;
	move_to_dir = get_global_position().direction_to(move_to_pos);


func start_move_to_center():
	var pos = get_global_position();
	$MovementTimer.stop();
	$FireTimer.paused = true;
	move_speed = 1000;
	moving = true;
	move_to_center = true;
	move_to_pos = Vector2(0, 0);
	move_to_dir = get_global_position().direction_to(move_to_pos);
	init_dist_to_center = sqrt(pow(move_to_pos.x-pos.x,2)+pow(move_to_pos.y-pos.y,2));
	if (init_dist_to_center <= 10):
		moving = false;
		move_to_center = false;
		$MovementTimer.start(movement_interval);
		$FireTimer.paused = false;
		if (is_instance_valid(last_trans_bullet)):
			get_parent().add_child(last_trans_bullet);
			last_trans_bullet.set_global_position(get_global_position());
		
func move_to_center():
	var pos = get_global_position();
	var min_speed = 20; 
	
	var dist_to_center = sqrt(pow(move_to_pos.x-pos.x,2)+pow(move_to_pos.y-pos.y,2));
	var dist_ratio = dist_to_center/init_dist_to_center;
	
	var move_vel = Vector2(
		move_to_dir.x*(min_speed+move_speed*dist_ratio), 
		move_to_dir.y*(min_speed+move_speed*dist_ratio)
	);
	if (move_vel.x > 1500 || move_vel.y > 1500):
		print("TOO FAST:");
		$FireTimer.paused = false;
		moving = false;
		move_to_center = false;
		if (is_instance_valid(last_trans_bullet)):
			get_parent().add_child(last_trans_bullet);
			last_trans_bullet.set_global_position(get_global_position());
		return;
	move_and_slide(move_vel, Vector2.UP);
	# once it reaches center
	if (dist_ratio < 0.05):
		$FireTimer.paused = false;
		moving = false;
		move_to_center = false;
		if (is_instance_valid(last_trans_bullet)):
			get_parent().add_child(last_trans_bullet);
			last_trans_bullet.set_global_position(get_global_position());
			
func move_to_random_pos():
	var pos = get_global_position();
	move_and_slide(move_to_dir * move_speed, Vector2.UP);
	if (
		pos.x < move_to_pos.x+dest_offset && pos.x > move_to_pos.x-dest_offset
		&& pos.y < move_to_pos.y+dest_offset && pos.y > move_to_pos.y-dest_offset
	):
		moving = false;
		$MovementTimer.start(movement_interval);

extends KinematicBody2D

var style = Global.initial_style
var prev_style = style;
var hit_by = []
var attack_pattern = 0;
var fire_rate = 1;
var rng = RandomNumberGenerator.new();
var enraged = false;
var hp = 0.0;

# movement
var move_to_pos = Vector2();
var move_to_dir = Vector2();
var pos_offset = 200;
var move_speed = 100;
var dest_offset = 10;
var moving = false;

onready var fire_timer = get_node("FireTimer");

var transbullet_state = false
var transbullet_cd = 1
var missed_bullet_counter = 0
var break_state = false

var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")

var laserInd = preload("res://objects/weapons/LaserIndicator.tscn")
var laserBeam = preload("res://objects/weapons/LaserBeam.tscn")

var attack_properties;


func _ready():
	Global.boss = self;
	_on_Verse_Jump(Global.initial_style);
	attack_pattern = rng.randi()%2;
	
func _physics_process(delta):
	if moving:
		var pos = get_global_position();
		move_and_slide(move_to_dir * move_speed, Vector2.UP);
		if (
			pos.x < move_to_pos.x+dest_offset && pos.x > move_to_pos.x-dest_offset
			&& pos.y < move_to_pos.y+dest_offset && pos.y > move_to_pos.y-dest_offset
		):
			moving = false;
			$MovementTimer.start();

func damage(amount,body = null):
	#print(body)
	#print("Boss have been damaged %d" % amount)
	Global.console.damage_boss(amount)
	
	# effects
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	
	Global.camera.shake(0.2, 6, 8)
	
	$HitSound.play()

func _on_Verse_Jump(verse):
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(0.5, 0.5), 0.05)
	
	yield(tween, "finished")
	get_node("Style%d" % style).hide()
	style = verse
	
	get_node("Style%d" % style).show()
	get_node("Style%d/TransEffect" % style).restart()
	get_node("Style%d/TransEffect" % style).set_emitting(true)
	
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)


func fireLaser(fireFrom, fireAt):
	
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
	rng.randomize();
	attack_pattern = rng.randi()%2;
	fire_timer.start();
	#print(transbullet_state)
	
	#firing portal bullet
	if transbullet_state == false:
		transbullet_cd -= 1
		#print(transbullet_cd)
		if transbullet_cd < 1:
			if not break_state:
				transbullet_cd = 5
				missed_bullet_counter += 1
			else:
				transbullet_cd = 1
				
			if missed_bullet_counter > 0:
				break_state = true
				missed_bullet_counter = 0
			var t = load("res://objects/weapons/TransBullet.tscn").instance()
			t.style = randi()%4
			#print("current style%d" % Global.current_style)
			
			if t.style == Global.current_style:
				t.style =(Global.current_style+1)%4

			get_parent().add_child(t);
			
			t.set_global_position(get_global_position());
			
			transbullet_state = true

func _on_FireTimer_timeout():
	fire_bullets();

func fire_bullets():
	attack_properties = Global.boss_patterns[style][attack_pattern];
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
			var b_speed = Global.boss_bullet_properties[style]["speed"];

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
			var b_speed = Global.boss_bullet_properties[style]["speed"];
			
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
			var b_speed = Global.boss_bullet_properties[style]["speed"];
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
			var num_waves = 8; var wave_interval = 0.1;
			var b_speed = Global.boss_bullet_properties[style]["speed"];
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
						fireLaser(get_global_position(), Vector2(x,y))
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
						fireLaser(get_global_position(), Vector2(x2,y2))
			yield(get_tree().create_timer(beamDuration), "timeout")
			finish_attack()
		1:
			var timeBetweenAttacks = 0.8
			for i in range(attack_properties["waves"]):
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				fireLaser(get_global_position(), Global.player.get_global_position())
				yield(get_tree().create_timer(attack_properties["interval"]), "timeout")
			finish_attack()
		_:
			pass

# 0: fire 2~ waves of shotgun shots of bouncing bullets towards the player
# 1: fire a singular circular shot
func init_collage_bullets():
	match attack_pattern:
		0:
			var num_waves = 2; var wave_interval = 0.6;
			var dir = get_global_position().direction_to(Global.player.get_global_position());
			var b_speed = Global.boss_bullet_properties[style]["speed"];
			for i in num_waves:
				if (!is_instance_valid(Global.boss)): return;
				if (prev_style != style):
					prev_style = style;
					finish_attack();
					return;
				fire_spread(3, 30, b_speed, dir);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		1:
			var b_speed = Global.boss_bullet_properties[style]["speed"];
			fire_pulse(6, b_speed);
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
	return b;

func fire_pulse(num, speed, offset=0.0, pos=get_global_position(), _style=style):
	var bullets = [];
	var degrees = 360.0/num;
	for i in num:
		var b = basic_bullet.instance();
		
		var radians = (offset+(i*degrees))*PI/180;
		var dir = Vector2(cos(radians), sin(radians));
		
		b.init_bullet(pos, dir, _style);
		b.set_linear_velocity(dir*speed);
		
		get_parent().add_child(b);
		bullets.append(b);
	return bullets;


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
	return bullets;


func _on_MovementTimer_timeout():
	rng.randomize();
	var pos_limit = Vector2(
		(Global.window_width-pos_offset)/2, 
		(Global.window_height-pos_offset)/2
	)
	var rand_pos = Vector2(
		rng.randi_range(-pos_limit.x, pos_limit.x), 
		rng.randi_range(-pos_limit.y, pos_limit.y)
	);
	print("timer done");
	moving = true;
	move_to_pos = rand_pos;
	move_to_dir = get_global_position().direction_to(move_to_pos);

extends KinematicBody2D

var style = Global.initial_style
var hit_by = []
var attack_pattern = 0;
var fire_rate = 1;
var rng = RandomNumberGenerator.new();
onready var fire_timer = get_node("FireTimer");

var transbullet_state = false
var transbullet_cd = 1

var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")

func _ready():
	Global.boss = self;
	attack_pattern = rng.randi()%2;

func damage(amount):
	print("Boss have been damaged %d" % amount)
	Global.console.damage_boss(amount)
	
	# effects
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	
	Global.camera.shake(0.2, 6, 3)

func _on_Verse_Jump(verse):
	if style == verse:
		return
	style = verse
	finish_attack();
	
	get_node("Style%d" % style).show()
	
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			#print("Style%d" % style)

func finish_attack():
	rng.randomize();
	attack_pattern = rng.randi()%2;
	fire_timer.start();
	print(transbullet_state)
	if transbullet_state == false:
		transbullet_cd -= 1
		print(transbullet_cd)
		if transbullet_cd < 1:
			transbullet_cd = 5
			var t = load("res://objects/weapons/TransBullet.tscn").instance()
			t.style = randi()%2
			if t.style == style:
				t.style =(style+1)%2
			get_parent().add_child(t);
			t.set_global_position(get_global_position());
			transbullet_state = true

func _on_FireTimer_timeout():
	fire_bullets();

func fire_bullets():
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
			var num_waves = 4; var wave_interval = 0.3; var offset_inc = 10;
			# instantiate the bullets
			# set the bullets properties to the one of the style
			for i in num_waves:
				fire_pulse(8, 300, offset_inc*i);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		1:
			var num_waves = 3; var wave_interval = 0.6; var num_bullets = 5;
			var bullet_speed = 600;
			for i in num_waves:
				var dir = get_global_position().direction_to(Global.player.get_global_position());
				fire_blob(num_bullets, bullet_speed, dir);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		_:
			pass

# 0: fire a wave of 4~ bullets towards the players position on firing, and blow them up when they reach there
# 1: fire bullets at random positions 7 times in quick successeon
func init_pixel_bullets():
	match attack_pattern:
		0:
			var num_waves = 6; var wave_interval = 0.3;
			for i in num_waves:
				var fire_pos = Global.player.get_global_position()
				var b = fire_at(fire_pos, 1000);
				b.set_detonate(fire_pos);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		1:
			var num_waves = 8; var wave_interval = 0.1;
			for i in num_waves:
				rng.randomize();
				var rand_pos = Vector2(
					rng.randi_range(-Global.window_width/2, Global.window_width/2), 
					rng.randi_range(-Global.window_height/2, Global.window_height/2)
				);
				var b = fire_at(rand_pos, 1000);
				b.set_detonate(rand_pos);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		_:
			pass

# 0: fires a wave of 4~ quick lasers towards the players position
# 1: shoot lasers in all directions, then rotate the lasers slowly around the boss (hades style)
func init_3d_bullets():
	pass

# 0: fire 2~ waves of shotgun shots of bouncing bullets towards the player
# 1: fire a singular circular shot
func init_collage_bullets():
	match attack_pattern:
		0:
			var num_waves = 2; var wave_interval = 0.6;
			var dir = get_global_position().direction_to(Global.player.get_global_position());
			for i in num_waves:
				fire_spread(3, 30, 300, dir);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		1:
			fire_pulse(6, 300);
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
func fire_blob(num, speed, dir, degree_offset=30, speed_offset=200, _style=style, pos=get_global_position()):
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

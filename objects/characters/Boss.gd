extends KinematicBody2D

var style = Global.initial_style
var hit_by = []
var attack_pattern = 0;
var rng = RandomNumberGenerator.new();
onready var fire_timer = get_node("FireTimer");

var basic_bullet = preload("res://objects/weapons/BasicBullet.tscn")

func damage(amount):
	print("Boss have been damaged %d" % amount)
	Global.console.damage_boss(amount)


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)

func finish_attack():
	rng.randomize();
	# attack_pattern = rng.randi()%2;
	fire_timer.start();

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
				fire_blob(num_bullets, bullet_speed);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		_:
			pass

# 0: fire a wave of 4~ bullets towards the players position on firing, and blow them up when they reach there
# 1: fire a series of bullets that; start from the center and extend to the outside.
func init_pixel_bullets():
	match attack_pattern:
		0:
			var num_waves = 4; var wave_interval = 0.5;
			for i in num_waves:
				var fire_pos = Global.player.get_global_position()
				var b = fire_at(fire_pos, 1000);
				b.set_detonate(fire_pos);
				yield(get_tree().create_timer(wave_interval), "timeout");
			finish_attack();
		1:
			pass
		_:
			pass

# 0: fires a wave of 4~ quick lasers towards the players position
# 1: shoot lasers in all directions, then rotate the lasers slowly around the boss (hades style)
func init_3d_bullets():
	pass

# 0: fire 2~ waves of shotgun shots of bouncing bullets towards the player
# 1: tbf
func init_collage_bullets():
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


func fire_spread(
	num, deg, speed, pos=get_global_position(), 
	fire_pos=Global.player.get_global_position(), _style=style
):
	var bullets = [];
	var odd = (num%2 != 0);
	for i in num:
		var b = basic_bullet.instance();
		var new_deg = 0.0;
		if !odd:
			new_deg = ((deg*1.5)+(i*deg))-(deg*(num-1));
		else:
			new_deg = (deg*(int(num/2))-(i*deg));
		new_deg *= PI/180;
		
		var dir = pos.direction_to(fire_pos);
		dir = Vector2(
			dir.x * (cos(new_deg)) + dir.y * (sin(new_deg)),
			dir.y * (cos(new_deg)) - dir.x * (sin(new_deg))
		);
		
		b.init_bullet(pos, dir, _style);
		b.set_linear_velocity(dir*speed);
		
		get_parent().add_child(b);
		bullets.append(b);

# num bullets at the approximate position of the player
# dir and speed are randomized within a range (deg and pixel respectfully)
func fire_blob(
	num, speed, degree_offset=30, speed_offset=200, 
	_style=style, pos=get_global_position(), fire_pos=Global.player.get_global_position()
):
	var bullets = [];
	for i in num:
		var b = basic_bullet.instance();
		
		rng.randomize();
		var new_deg = rng.randi_range(-degree_offset/2, degree_offset/2) * PI/180;
		var new_speed = rng.randi_range(-speed_offset/2, speed_offset/2) + speed;
		
		var dir = pos.direction_to(fire_pos);
		dir = Vector2(
			dir.x * (cos(new_deg)) + dir.y * (sin(new_deg)),
			dir.y * (cos(new_deg)) - dir.x * (sin(new_deg))
		)
		
		b.init_bullet(pos, dir, _style);
		b.set_linear_velocity(dir*new_speed);
		
		get_parent().add_child(b);
		bullets.append(b);

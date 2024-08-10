

extends KinematicBody2D

var style = Global.initial_style

var velocity = Vector2.ZERO
export var speed = 400
var speed_mult = 1.0;
# var shooting = false;

var max_health = 100
var health = max_health;
var health_regen_speed = 2
var style_scales = {};

var holdTime = 0.0
var maxHoldTime = 1.0;

var is_created = false
var chargeShot

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")
var pixel_bullet = preload("res://arts/pixelArt/fireball.png")
var bullet_properties = Global.player_bullet_properties[style];

func _ready():
	Global.player = self
	self.modulate = Color(1, 1, 1, 0);
	$Tween.interpolate_property(self, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.2);
	$Tween.start();
	var init_style = Global.initial_style;
	if (Global.in_tutorial):
		init_style = Global.tutorial_style;
	for i in Global.total_style:
		var sprite = get_node("Style%d/AnimatedSprite"%i)
		if (is_instance_valid(sprite)):
			style_scales[i] = sprite.scale;
			print(style_scales[i]);
	_on_Verse_Jump(init_style);

func init_difficulty(difficulty):
	speed =  Global.player_stats[difficulty]["move speed"];
	max_health = Global.player_stats[difficulty]["hp"];
	health = max_health;
	health_regen_speed = Global.player_stats[difficulty]["hp regen"];

func _process(delta):
	if (style == 2):
		if Input.is_action_pressed("fire_action"):
			var dir = Global._get_input_direction(self);
			var shot_pos = $Style2/AnimatedSprite/Shot.get_global_position();
			
			if !is_created:
				is_created = true
				chargeShot = bullet.instance()
				get_parent().add_child(chargeShot);
				chargeShot.get_node("CollisionShape2D").disabled = true
				chargeShot.init_bullet(shot_pos, dir, style);
			if (is_instance_valid(chargeShot)):
				chargeShot.set_global_position(shot_pos);
				chargeShot.set_bullet_rotation(dir)
				chargeShot.charge = holdTime / maxHoldTime
				if holdTime >= 1.0: 
					chargeShot.charge = 1.0;
					is_created = false
					chargeShot.queue_free()
					fire_bullet();
					holdTime = 0.0;
					$FireTimer.start()
				else:
					holdTime += delta
			
		if Input.is_action_just_released("fire_action") && is_instance_valid(chargeShot):
			is_created = false
			chargeShot.queue_free()
			fire_bullet();
			holdTime = 0.0;
			$FireTimer.start()
	else:
		if (is_instance_valid(chargeShot)):
			chargeShot.queue_free();
			is_created = false;
			holdTime = 0.0;
		if Input.is_action_pressed("fire_action"):
			# shooting = true;
			if ($FireTimer.is_stopped()):
				fire_bullet()
				$FireTimer.start()
	if (Input.is_action_pressed("holding_shift")):
		speed_mult = 0.5;
		$CollisionIndi.modulate.a = 0.25
	else:
		speed_mult = 1.0;
		$CollisionIndi.modulate.a = 0
	
	# rotate the sprite toward player in minimalistic style
	if style == 0:
		if Global.gamepad_input_mode:
			$Style0/AnimatedSprite.look_at($Style0/AnimatedSprite.get_global_position() + Global.last_joystick_direction)
		else:
			$Style0/AnimatedSprite.look_at(get_global_mouse_position())
	
	# regenerate health
	if $RegenerateTimer.is_stopped():
		health = clamp(health + delta * health_regen_speed, 0, max_health)
		
		if health >= max_health:
			$HealthBar.hide()
	
	# update health ui
	if $HealthBar.is_visible():
		#$HealthBar.set_value(lerp($HealthBar.get_value(), health, delta * 5))
		$HealthBar.set_value(health)


func _physics_process(delta):
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
	
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	
	move_and_slide(velocity * speed*speed_mult, Vector2.UP)
	
	# bound the player to the viewport
	position.x = clamp(position.x, -get_viewport_rect().size.x/2, get_viewport_rect().size.x/2)
	position.y = clamp(position.y, -get_viewport_rect().size.y/2, get_viewport_rect().size.y/2)

func _input(event):
	return;
	if event is InputEventKey:
		var keyPressed = event.scancode
		if keyPressed in [48,49,50,51]:
			var new_style = keyPressed - 48
			Global.current_style = new_style
			for node in get_tree().get_nodes_in_group('style'):
				node._on_Verse_Jump(new_style)
				# print(new_style)

func _on_Verse_Jump(verse):
	style = verse
	get_node("Style%d" % style).show()
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
	
	get_node("Style%d/TransEffect" % style).restart()
	get_node("Style%d/TransEffect" % style).set_emitting(true)
	
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	
	bullet_properties = Global.player_bullet_properties[style];
	$FireTimer.wait_time = bullet_properties["fire rate"];


# fires a bullet at the mouse position
func fire_bullet():
	var shotLocations = get_tree().get_nodes_in_group('shots%d' % style)
	for shot in shotLocations:
		var s_scale = style_scales[style];
		match style:
			0:
				init_minimal_bullets(shot);
				
				# effects
				$Style0/AnimatedSprite.set_scale(s_scale*0.7)
				$Style0/AnimatedSprite/Playercircle.set_scale(Vector2(4, 4))
				$Style0/AnimatedSprite/Playercircle2.set_scale(Vector2(4, 4))
				var tween = create_tween().set_trans(Tween.TRANS_SINE)
				tween.tween_property($Style0/AnimatedSprite/Playercircle, "scale", s_scale, 0.2)
				tween.parallel().tween_property($Style0/AnimatedSprite/Playercircle2, "scale", s_scale, 0.2)
				tween.parallel().tween_property($Style0/AnimatedSprite, "scale", s_scale, 0.2)
			1:
				init_pixel_bullets(shot);
				
				# effects
				$Style1/AnimatedSprite.set_scale(s_scale*0.8)
				var tween = create_tween().set_trans(Tween.TRANS_SINE)
				tween.tween_property($Style1/AnimatedSprite, "scale", s_scale, 0.2)
			2:
				init_3d_bullets(shot);
				
				# effects
				$Style2/AnimatedSprite.set_scale(s_scale*0.7)
				var tween = create_tween().set_trans(Tween.TRANS_SINE)
				tween.tween_property($Style2/AnimatedSprite, "scale", s_scale, 0.2)
			3:
				init_collage_bullets(shot);
				
				# effects
				$Style3/AnimatedSprite.set_scale(s_scale*0.7)
				var tween = create_tween().set_trans(Tween.TRANS_SINE)
				tween.tween_property($Style3/AnimatedSprite, "scale", s_scale, 0.2)
			_:
				pass
			
	# play sounds
	get_node("Style%d/FireSound" % style).play()


func init_minimal_bullets(shot):
	var b = bullet.instance()
	get_parent().add_child(b);
	
	var dir = Global._get_input_direction(self);
	b.init_bullet(shot.get_global_position(), dir, style);
	b.set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);
		

func init_pixel_bullets(shot):
	var b = bullet.instance();
	get_parent().add_child(b)
	
	var dir = Global._get_input_direction(shot);
	b.init_bullet(shot.get_global_position(), dir, style);
	
	# pixel bullet detonate fix
	if Global.gamepad_input_mode:
		b.set_detonate(get_global_position() + dir * 700);
	else:
		b.set_detonate(get_global_mouse_position());
	
	b.set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);
	

func init_3d_bullets(shot):
	var charge = holdTime / maxHoldTime;
	var num_bullets = 0;
	var deg = 10;
	if (charge > 1.0): charge = 1.0;
	if (charge < 2.0/3.0):
		num_bullets = 1;
		deg = 0;
	elif (charge < 1.0):
		num_bullets = 2;
	else:
		num_bullets = 3;

	# fire spread depending on charge
	var dir = Global._get_input_direction(shot);
	var bullets = fire_spread(num_bullets, deg, Global.player_bullet_properties[style]["speed"], dir, 0.6, shot.get_global_position());
	for b in bullets:
		b.charge = charge;
		# print("print damage: %f charge %f" % [b.damage, charge]);
	
	
func init_collage_bullets(shot):
	var dir = Global._get_input_direction(shot);
	var bullets = fire_spread(3, 10, Global.player_bullet_properties[style]["speed"], dir, 1.0, shot.get_global_position());


func damage(amount):
	("Player have been damaged %d" % amount)
	health -= amount
	
	$HealthBar.show()
	$HealthBar.set_modulate(Color.white)
	
	var tween = create_tween()
	tween.tween_property($HealthBar, "modulate", Color("64ffffff"), 0.3)
	#tween.tween_property(self, "scale", Vector2(1.0,1.0), 0.08)
	var tween1 = create_tween().set_trans(Tween.TRANS_CUBIC)
	#var tween2 = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween1.tween_property(self, "modulate", Color("e60000"), 0.13)
	#tween2.tween_property($HealthBar, "rect_scale", Vector2(1.5,1.5), 0.08)
	tween1.set_trans(Tween.TRANS_LINEAR)
	#tween1.tween_property($HealthBar, "scale", Vector2(1,1), 0.12)
	tween1.tween_property(self, "modulate", Color("ffffff"), 0.12)
	#tween2.tween_property($HealthBar, "rect_scale", Vector2(1,1), 0.12)
	
	# tween animation for when player is hit
	get_node("Style%d" % style).set_scale(Vector2(0.5, 0.5))
	var hit_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	hit_tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.4)
	
	Global.camera.shake(0.2, 10, 10);
	# wait a bit before regenerate health
	$RegenerateTimer.start()
	get_node("Style%d/HitSound" % style).play()
	
	Global.camera.shake(0.3, 12, 8)
	
	if health <= 0:
		#print("You DEAD!!!")
		
		# hide all the graphics
		hide()
		
		Global.console.player_dead()
		#get_tree().reload_current_scene()


func fire_spread(
	num, deg, speed, dir, damage_mult, pos=get_global_position(), _style=style
):
	var bullets = [];
	var odd = (num%2 != 0);
	for i in num:
		var b = bullet.instance();
		get_parent().add_child(b);
		
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
		b.damage = Global.player_bullet_properties[_style]["damage"] * damage_mult;
		
		bullets.append(b);
	return bullets;

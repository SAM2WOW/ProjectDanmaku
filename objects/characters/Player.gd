

extends KinematicBody2D

var style = Global.initial_style

var velocity = Vector2.ZERO
export var speed = 500
var speed_mult = 1.0;

# var shooting = false;

var max_health = 100;
var health = max_health;
var health_regen_speed = 8

var holdTime = 0
var maxHoldTime = 1.0;

var is_created = false
var chargeShot

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")
var pixel_bullet = preload("res://arts/pixelArt/fireball.png")
var bullet_properties = Global.player_bullet_properties[style];

func _ready():
	Global.player = self
	_on_Verse_Jump(Global.initial_style);

func _process(delta):
	if (style == 2):
		if Input.is_action_pressed("mouse_action"):
			var dir = get_global_position().direction_to(get_global_mouse_position());
			if !is_created:
				is_created = true
				chargeShot = bullet.instance()
				get_parent().add_child(chargeShot);
				chargeShot.get_node("CollisionShape2D").disabled = true
				chargeShot.init_bullet(get_node("Style2").get_node("AnimatedSprite").get_node("3DShot").get_global_position(), dir, style);
			chargeShot.set_global_position(get_node("Style2").get_node("AnimatedSprite").get_node("3DShot").get_global_position())
			chargeShot.set_bullet_rotation(dir)
			chargeShot.charge = holdTime / maxHoldTime
			if holdTime > 1.0: chargeShot.charge = 1.0
			var tween_values = [Color(1,1,1), Color(2,2,2)]
			if holdTime >= maxHoldTime && (self.modulate == tween_values[0] || self.modulate == tween_values[1]):
				$ReadyFlash.interpolate_property(self, "modulate", tween_values[1], tween_values[0], 1, Tween.TRANS_LINEAR)
				$ReadyFlash.start()
			holdTime += delta
		if Input.is_action_just_released("mouse_action"):
			is_created = false
			chargeShot.queue_free()
			$ReadyFlash.remove_all()
			self.modulate = Color(1,1,1)
			fire_bullet();
			holdTime = 0.0;
			$FireTimer.start()
	else:
		if Input.is_action_pressed("mouse_action"):
			# shooting = true;
			if ($FireTimer.is_stopped()):
				fire_bullet()
				$FireTimer.start()
	if (Input.is_action_pressed("holding_shift")):
		speed_mult = 0.5;
	else:
		speed_mult = 1.0;
	
	# rotate the sprite toward player in minimalistic style
	if style == 0:
		$Style0/Icon.look_at(get_global_mouse_position())
	
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
	if event is InputEventKey:
		var keyPressed = event.scancode
		if keyPressed in [48,49,50,51]:
			var new_style = keyPressed - 48
			Global.current_style = new_style
			for node in get_tree().get_nodes_in_group('style'):
				node._on_Verse_Jump(new_style)
				# print(new_style)

func _on_Verse_Jump(verse):
	get_node("Style%d" % style).hide()
	style = verse
	
	get_node("Style%d" % style).show()
	get_node("Style%d/TransEffect" % style).restart()
	get_node("Style%d/TransEffect" % style).set_emitting(true)
	
	get_node("Style%d" % style).set_scale(Vector2(0.7, 0.7))
	var tween = create_tween().set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(get_node("Style%d" % style), "scale", Vector2(1, 1), 0.2)
	
	bullet_properties = Global.player_bullet_properties[style];
	$FireTimer.wait_time = bullet_properties["fire rate"];


# fires a bullet at the mouse position
func fire_bullet():
	match style:
		0:
			init_minimal_bullets();
			
			# effects
			$Style0/Icon.set_scale(Vector2(0.7, 0.7))
			$Style0/Icon/Playercircle.set_scale(Vector2(4, 4))
			$Style0/Icon/Playercircle2.set_scale(Vector2(4, 4))
			var tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property($Style0/Icon/Playercircle, "scale", Vector2(1, 1), 0.2)
			tween.parallel().tween_property($Style0/Icon/Playercircle2, "scale", Vector2(1, 1), 0.2)
			tween.parallel().tween_property($Style0/Icon, "scale", Vector2(1, 1), 0.2)
		1:
			init_pixel_bullets();
			
			# effects
			$Style1/AnimatedSprite.set_scale(Vector2(2.5, 2.5))
			var tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property($Style1/AnimatedSprite, "scale", Vector2(3, 3), 0.2)
		2:
			init_3d_bullets();
			
			# effects
			$Style2/AnimatedSprite.set_scale(Vector2(0.12, 0.12))
			var tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property($Style2/AnimatedSprite, "scale", Vector2(0.137, 0.137), 0.2)
		3:
			init_collage_bullets();
		_:
			pass
		
	# play sounds
	get_node("Style%d/FireSound" % style).play()


func init_minimal_bullets():
	var shotLocations = get_tree().get_nodes_in_group('shots%d' % style)
	for shot in shotLocations:
		var b = bullet.instance()
		get_parent().add_child(b);
		
		var dir = get_global_position().direction_to(get_global_mouse_position());
		b.init_bullet(shot.get_global_position(), dir, style);
		b.set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);
		

func init_pixel_bullets():
	var b = bullet.instance();
	get_parent().add_child(b)
	
	var dir = get_global_position().direction_to(get_global_mouse_position());
	b.init_bullet(get_global_position(), dir, style);
	b.set_detonate(get_global_mouse_position());
	b.set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);
	

func init_3d_bullets():
	var charge = holdTime / maxHoldTime;
	if (charge > 1.0): charge = 1.0;

	var b = bullet.instance();
	get_parent().add_child(b)
	b.charge = charge;
	var dir = get_global_position().direction_to(get_global_mouse_position());
	b.init_bullet(get_global_position(), dir, style);
	b.set_linear_velocity(dir*Global.player_bullet_properties[style]["speed"]);
	
	
func init_collage_bullets():
	var dir = get_global_position().direction_to(get_global_mouse_position());
	var bullets = fire_spread(3, 15, Global.player_bullet_properties[style]["speed"], dir);


func damage(amount):
	print("Player have been damaged %d" % amount)
	health -= amount
	
	$HealthBar.show()
	# wait a bit before regenerate health
	$RegenerateTimer.start()
	
	Global.camera.shake(0.3, 12, 4)
	
	if health <= 0:
		print("You DEAD!!!")
		
		Global.console.player_dead()
		
		queue_free()
		#get_tree().reload_current_scene()


func fire_spread(
	num, deg, speed, dir, pos=get_global_position(), _style=style
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
		b.damage = Global.player_bullet_properties[_style]["damage"];
		
		bullets.append(b);
	return bullets;

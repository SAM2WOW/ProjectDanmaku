

extends KinematicBody2D

var style = Global.initial_style

var velocity = Vector2.ZERO
export var speed = 500
var speed_mult = 1.0;

onready var firingPositions = $FiringPositions

# var shooting = false;

var health = 100

var holdTime = 0
var maxHoldTime = 1.0;

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")
var pixel_bullet = preload("res://arts/pixelArt/fireball.png")
var bullet_properties = Global.player_bullet_properties[style];

func _ready():
	Global.player = self


func _process(delta):
	if (style == 2):
		if Input.is_action_pressed("mouse_action"):
			var tween_values = [Color(1,1,1), Color(2,2,2)]
			if holdTime >= maxHoldTime && (self.modulate == tween_values[0] || self.modulate == tween_values[1]):
				$ReadyFlash.interpolate_property(self, "modulate", tween_values[1], tween_values[0], 1, Tween.TRANS_LINEAR)
				$ReadyFlash.start()
			holdTime += delta
		if Input.is_action_just_released("mouse_action"):
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
		# else:
			# shooting = false;
	
	# rotate the sprite toward player in minimalistic style
	if style == 0:
		$Style0/Icon.look_at(get_global_mouse_position())

func _input(event):
	if event is InputEventKey:
		var keyPressed = event.scancode
		if keyPressed in [48,49,50,51]:
			var new_style = keyPressed - 48
			Global.prev_style = Global.current_style
			Global.current_style = new_style
			for node in get_tree().get_nodes_in_group('style'):
				node._on_Verse_Jump(new_style)
				# print(new_style)

# Andrew: for some reason the input functions didnt work every frame, so I moved the code to process
func _unhandled_input(event):
	pass


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

# fires a bullet at the mouse position
func fire_bullet():
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
			var b = bullet.instance();
			b.style = 2;
			b.dir = get_global_position().direction_to(get_global_mouse_position());
			b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
			get_parent().add_child(b)
			b.init_normal_bullet(get_global_position(), style);
	
	# play sounds
	get_node("Style%d/FireSound" % style).play()


func init_minimal_bullets():
	var shotLocations = [Global.player];
	shotLocations = get_tree().get_nodes_in_group('shots')
	for shot in shotLocations:
		var b = bullet.instance()
		b.dir = get_global_position().direction_to(get_global_mouse_position());
		get_parent().add_child(b);
		b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
		b.init_minimal_bullet(shot.get_global_position(), style);

func init_pixel_bullets():
	var b = bullet.instance();
	b.dir = get_global_position().direction_to(get_global_mouse_position());
	b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
	get_parent().add_child(b)
	b.init_pixel_bullet(get_global_position(), style, get_global_mouse_position());

func init_3d_bullets():
	var charge = holdTime / maxHoldTime;
	if (charge > 1.0): charge = 1.0;
	
	var b = bullet.instance();
	b.dir = get_global_position().direction_to(get_global_mouse_position());
	b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
	get_parent().add_child(b)
	b.init_3d_bullet(get_global_position(), style, charge);
	
func init_collage_bullets():
	var b = bullet.instance();
	b.dir = get_global_position().direction_to(get_global_mouse_position());
	b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
	get_parent().add_child(b)
	b.init_collage_bullet(get_global_position(), style);

func damage(amount):
	print("Player have been damaged %d" % amount)
	health -= amount
	
	if health <= 0:
		print("You DEAD!!!")
		
		get_tree().reload_current_scene()

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
	get_node("FireTimer").wait_time = bullet_properties["fire rate"];

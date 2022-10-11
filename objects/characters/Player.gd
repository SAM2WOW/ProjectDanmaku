

extends KinematicBody2D

var style = Global.initial_style

var velocity = Vector2.ZERO
export var speed = 300
# var shooting = false;

var health = 100

var holdTime = 0

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")
var pixel_bullet = preload("res://arts/pixelArt/fireball.png")
var bullet_properties = Global.player_bullet_properties[style];

func _ready():
	Global.player = self


func _process(delta):
	if (style == 2):
		if Input.is_action_pressed("mouse_action"):
			var tween_values = [Color(1,1,1), Color(2,2,2)]
			if holdTime >= 1 && (self.modulate == tween_values[0] || self.modulate == tween_values[1]):
				$ReadyFlash.interpolate_property(self, "modulate", tween_values[1], tween_values[0], 1, Tween.TRANS_LINEAR)
				$ReadyFlash.start()
			holdTime += delta
		if Input.is_action_just_released("mouse_action"):
			$ReadyFlash.remove_all()
			self.modulate = Color(1,1,1)
			fire_bullet(calculate_charge(holdTime))
			holdTime = 0
			$FireTimer.start()
	else:
		if Input.is_action_pressed("mouse_action"):
			# shooting = true;
			if ($FireTimer.is_stopped()):
				fire_bullet(0)
				$FireTimer.start()
		# else:
			# shooting = false;
	
	# rotate the sprite toward player in minimalistic style
	if style == 0:
		$Style0/Icon.look_at(get_global_mouse_position())

func _input(event):
	if event is InputEventKey:
		var keyPressed = event.scancode
		if keyPressed in [48,49,50]:
			var new_style = keyPressed - 48
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
	
	move_and_slide(velocity * speed, Vector2.UP)
	
	# bound the player to the viewport
	position.x = clamp(position.x, -get_viewport_rect().size.x/2, get_viewport_rect().size.x/2)
	position.y = clamp(position.y, -get_viewport_rect().size.y/2, get_viewport_rect().size.y/2)


# fires a bullet at the mouse position
func fire_bullet(charge):
	var b_speed = 700;
	var shotLocations = [Global.player]
	if (style == 0):
		shotLocations = get_tree().get_nodes_in_group('shots')
		
	for shot in shotLocations:
		var b = bullet.instance()
		
		b.damage += charge * 20
		b.scale *= charge * 10
		if charge == 1:
			b.damage = 100
		
		print(b.damage)
		
		b._on_Verse_Jump(style)
		get_parent().add_child(b)
		b.set_global_position(shot.get_global_position())
		
		var dir = get_global_position().direction_to(get_global_mouse_position())
		b.dir = dir;
		b.rotation = 2*PI + atan2(dir.y, dir.x);
		b.set_linear_velocity(dir*b_speed);
		
		if (style == 1):
			instance_pixel_bullet(b);

# func for calculating charge amount of bullet
func calculate_charge(time):
	var charge = time
	if time > 1:
		charge = 1
	return charge

func instance_pixel_bullet(b):
	var linear_vel = sqrt(pow(b.linear_velocity.x,2)+pow(b.linear_velocity.y,2));
	var dist = sqrt(pow(get_global_mouse_position().x-get_global_position().x, 2)+pow(get_global_mouse_position().y-get_global_position().y, 2));
	# the amt of time it takes the bullet to reach the distance it explodes
	var explode_timer = (dist*0.75)/linear_vel;
	b.get_node("Style1/ExplodeTimer").start(explode_timer);
func fire_bullet():
	var b = bullet.instance()
	b.dir = get_global_position().direction_to(get_global_mouse_position());
	b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
	b.bullet_properties = Global.player_bullet_properties[style];
	get_parent().add_child(b)

	match style:
		1:
			b.init_pixel_bullet(get_global_position(), style);
		_:
			b.init_normal_bullet(get_global_position(), style);
	
func damage(amount):
	print("Player have been damaged %d" % amount)
	health -= amount
	
	if health <= 0:
		print("You DEAD!!!")
		
		get_tree().reload_current_scene()

func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)
	
	bullet_properties = Global.player_bullet_properties[style];
	get_node("FireTimer").wait_time = bullet_properties["fire rate"];

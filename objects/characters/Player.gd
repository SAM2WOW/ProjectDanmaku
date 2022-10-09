extends KinematicBody2D

var style = Global.initial_style

var velocity = Vector2.ZERO
export var speed = 300
var shooting = false;

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")


func _ready():
	Global.player = self


func _process(delta):
	if Input.is_action_pressed("mouse_action"):
		shooting = true;
		if ($FireTimer.is_stopped()):
			fire_bullet();
			$FireTimer.start();
		else:
			shooting = false;
	
	# rotate the sprite toward player in minimalistic style
	if style == 0:
		$Style0/Icon.look_at(get_global_mouse_position())


func _input(event):
	if event is InputEventKey:
		var keyPressed = event.scancode
		if keyPressed in [48,49,50]:
			for node in get_tree().get_nodes_in_group('style'):
				node._on_Verse_Jump(keyPressed - 48)
				# print(keyPressed - 48)

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
func fire_bullet():
	var b_speed = 700;
	var b = bullet.instance()

	b.style = style
	b._on_Verse_Jump(style)
	
	get_parent().add_child(b)
	b.set_global_position(get_global_position())
	
	var dir = get_global_position().direction_to(get_global_mouse_position())
	b.rotation = 2*PI + atan2(dir.y, dir.x);
	# b.add_force(Vector2.ZERO, dir * 200)
	b.set_linear_velocity(dir*b_speed);
	

func _on_Timer_timeout():
	pass


func damage(amount):
	print("Player have been damaged %d" % amount)


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)

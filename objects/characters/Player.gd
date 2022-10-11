extends KinematicBody2D

var style = Global.initial_style

var velocity = Vector2.ZERO
export var speed = 300
# var shooting = false;

var health = 100

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")

onready var firingPositions = $FiringPositions


func _ready():
	Global.player = self


func _process(delta):
	if Input.is_action_pressed("mouse_action"):
		# shooting = true;
		if ($FireTimer.is_stopped()):
			fire_bullet();
			$FireTimer.start();
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
func fire_bullet():


	# var b_instances = [];
	
	var b = bullet.instance()
	b.dir = get_global_position().direction_to(get_global_mouse_position());
	b.rotation = 2*PI + atan2(b.dir.y, b.dir.x);
	b.bullet_properties = Global.player_bullet_properties[style];
	get_parent().add_child(b)
	
	var shotLocations = [Global.player]
	if (style == 0):
		shotLocations = firingPositions.get_children();
	
	match style:
#		0:
#			print("min bullet");
#			for shot in shotLocations:
#				b.init_minimal_bullet(shotLocations, style);
		1:
			# for bu in b_instances:
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

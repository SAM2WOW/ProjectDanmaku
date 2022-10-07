extends KinematicBody2D

var style = 0

var velocity = Vector2.ZERO
export var speed = 300

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")


func _ready():
	Global.player = self


func _input(event):
	if event is InputEventKey:
		var keyPressed = event.scancode
		if keyPressed in [48,49,50]:
			for node in get_tree().get_nodes_in_group('bullet'):
				node._on_Verse_Jump(keyPressed - 48)
				#print(keyPressed - 48)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			$FireTimer.start()
		else:
			$FireTimer.stop()


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


func _on_Timer_timeout():
	# fire bullets
	var b = bullet.instance()

	b.style = style
	b._on_Verse_Jump(style)
	
	get_parent().add_child(b)
	b.set_global_position(get_global_position())
	
	var dir = get_global_position().direction_to(get_global_mouse_position())
	b.add_force(Vector2.ZERO, dir * 200)


func damage(amount):
	print("Player have been damaged %d" % amount)


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(2):
		if i != style:
			get_node("Style%d" % i).hide()
			print("Style%d" % style)

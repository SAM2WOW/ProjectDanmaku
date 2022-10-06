extends KinematicBody2D


var velocity = Vector2.ZERO
export var speed = 300


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(get_global_mouse_position())


func _physics_process(delta):
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
	
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	
	move_and_slide(velocity * speed, Vector2.UP)
	velocity = Vector2.ZERO

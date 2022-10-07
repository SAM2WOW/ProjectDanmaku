extends KinematicBody2D


var velocity = Vector2.ZERO
export var speed = 300


var bullet = preload("res://Bullet.tscn")


func _input(event):
	if Input.is_action_just_pressed("shoot"):
		var b = bullet.instance()
		get_parent().add_child(b)
		b.set_global_position(get_global_position())


func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		velocity.y = -1
	
	if Input.is_action_pressed("ui_down"):
		velocity.y = 1
	
	if Input.is_action_pressed("ui_right"):
		velocity.x = 1
	
	if Input.is_action_pressed("ui_left"):
		velocity.x = -1
	
	move_and_slide(velocity * speed, Vector2.UP)
	velocity = Vector2.ZERO
	

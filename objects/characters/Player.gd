extends KinematicBody2D


var velocity = Vector2.ZERO
export var speed = 300

var bullet = preload("res://objects/weapons/PlayerBullet.tscn")


func _input(event):
	pass


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var b = bullet.instance()
			get_parent().add_child(b)
			b.set_global_position(get_global_position())
			
			var dir = get_global_position().direction_to(get_global_mouse_position())
			b.add_force(Vector2.ZERO, dir * 200)


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

extends AnimatedSprite


# Declare member variables here. Examples:
var player_node;
var player_vel = Vector2();

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_node("/root/Main/Node2D/Player");
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_sprite = player_node.get_node("./Style1/AnimatedSprite");
	# if the player is shooting, flip them the direction the mouse is
	if (player_node.shooting):
		var dir = get_global_position().direction_to(get_global_mouse_position());
		if (dir.x >= 0):
			player_sprite.set_flip_h(true);
		else:
			player_sprite.set_flip_h(false);
	# if they aren't shooting, flip them the direction they're moving
	else:
		player_vel = player_node.velocity;
		if (player_vel.x > 0):
			player_sprite.set_flip_h(true);
		elif (player_vel.x < 0):
			player_sprite.set_flip_h(false);

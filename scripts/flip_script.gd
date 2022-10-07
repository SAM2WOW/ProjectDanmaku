extends AnimatedSprite


# Declare member variables here. Examples:
var dir = 1;
var player_node;
var player_vel = Vector2();

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_node("/root/Main/Node2D/Player");
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player_vel = player_node.velocity;
	var player_sprite = player_node.get_node("./Style1/AnimatedSprite");
	if (player_vel.x > 0):
		player_sprite.set_flip_h(true);
	elif (player_vel.x < 0):
		player_sprite.set_flip_h(false);

extends AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = get_global_position().direction_to(get_global_mouse_position());
	if (dir.x >= 0):
		self.set_flip_h(true);
	else:
		self.set_flip_h(false);
		

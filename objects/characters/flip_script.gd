extends AnimatedSprite

var shot
var ogPosition

# Called when the node enters the scene tree for the first time.
func _ready():
	shot = get_node("Shot")
	ogPosition = shot.get_position()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var dir = Global._get_input_direction(self)
	if (dir.x >= 0):
		self.set_flip_h(true);
		if Global.current_style != 0:
			shot.set_position(Vector2(-ogPosition[0], ogPosition[1]))
	else:
		self.set_flip_h(false);

		if Global.current_style != 0:
			shot.set_position(Vector2(ogPosition[0], ogPosition[1]))

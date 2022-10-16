extends Position2D


var amount = 0;
var type = "normal"
var text_speed = 200;
var display_dur = 0.15;

var velocity = Vector2();
# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.set_text(str(int(amount)));
	match type:
		"normal":
			$Label.set("custom_colors/font_color", Color("ffffff"));
			display_dur = 0.15;
		"critical":
			$Label.set("custom_colors/font_color", Color("#FF0000"));
			scale *= 1.5;
			display_dur = 0.3;
			text_speed =  int(text_speed * 0.8);
	randomize();
	# x dir can be anywhere between
	var text_x_dir = randi() % text_speed - (text_speed * 0.4);
	velocity = Vector2(text_x_dir, text_speed);
	
	# scaling tween: args: obj, tween type, init_scale, to_scale, duration, type of tweens, (optional: tween delay)
	$Tween.interpolate_property(self, 'scale', scale, scale*1.2, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT);
	$Tween.interpolate_property(self, 'scale', scale*1.2, scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, display_dur);
	$Tween.interpolate_property(self, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, display_dur);
	$Tween.start();

func _physics_process(delta):
	position -= velocity*delta;

func _on_Tween_tween_all_completed():
	queue_free();

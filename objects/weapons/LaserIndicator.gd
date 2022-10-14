extends Line2D


func _ready():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "width", 10.0, 0.2)

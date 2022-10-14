extends Node2D

var tween1
func ready_tween(size_mult):
	show()
	tween1 = create_tween().set_trans(Tween.TRANS_QUAD)
	tween1.tween_property($arrow, "position", Vector2(0, -50 * size_mult), 0.25)
	tween1.set_trans(Tween.TRANS_CUBIC)
	tween1.tween_property($arrow, "position", Vector2(0, -100 * size_mult), 0.5)
	tween1.set_loops(-1)

func end_tween():
	tween1.kill()
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($arrow, "position", Vector2(0, -2000), 0.5)
	tween.tween_property($arrow, "modulate", Color(255,255,255,0), 0.1)

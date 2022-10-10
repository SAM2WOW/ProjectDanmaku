extends Node2D


var previous_style = {}
export var style = 0


func _ready():
	$Sprite.set_material(load("res://arts/shaders/Style%d.tres" % style))
	
	set_scale(Vector2(0, 0))
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 1)


func _on_Area2D_body_entered(body):
	if body.has_method('_on_Verse_Jump'):
		previous_style[body.name] = body.style
		body._on_Verse_Jump(style)


func _on_Area2D_body_exited(body):
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(previous_style[body.name])
		previous_style.erase(body.name)

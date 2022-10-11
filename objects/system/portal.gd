extends Node2D


export var style = 0


func _ready():
	#$Sprite.set_material(load("res://arts/shaders/Style%d.tres" % style))
	#$Sprite/CPUParticles2D.set_material(load("res://arts/shaders/Style%d.tres" % style))
	
	set_scale(Vector2(0, 0))
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "scale", Vector2(1, 1), 1)


func _on_Area2D_body_entered(body):
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(style)


func _on_Area2D_body_exited(body):
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(Global.current_style)
	if body.has_method('_on_Verse_Exit'):
		body._on_Verse_Exit(Global.prev_style, Global.current_style)

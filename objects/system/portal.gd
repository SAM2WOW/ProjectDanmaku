extends Node2D


var previous_style = {}
export var style = 0


func _on_Area2D_body_entered(body):
	if body.has_method('_on_Verse_Jump'):
		previous_style[body.name] = body.style
		body._on_Verse_Jump(style)


func _on_Area2D_body_exited(body):
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(previous_style[body.name])
		previous_style.erase(body.name)

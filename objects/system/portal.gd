extends Node2D


var player_style = 0
export var style = 0


func _on_Area2D_body_entered(body):
	if body.has_method('_on_Verse_Jump'):
		player_style = body.style
		body._on_Verse_Jump(style)


func _on_Area2D_body_exited(body):
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(player_style)

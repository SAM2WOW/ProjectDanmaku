extends Node2D


export var style = 0
var exploding = false

func _ready():
	#$Sprite.set_material(load("res://arts/shaders/Style%d.tres" % style))
	#$Sprite/CPUParticles2D.set_material(load("res://arts/shaders/Style%d.tres" % style))
	set_scale(Vector2(0, 0))
	if not exploding:
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "scale", Vector2(1, 1), 1)
	else:
		verse_jump_explode()
		
func _process(delta):
	if exploding and $Area2D.get_overlapping_bodies().size() > 0:
		for i in $Area2D.get_overlapping_bodies():
			i._on_Verse_Jump(style)
			
func verse_jump_explode():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(10, 10), 0.6)
	tween.tween_callback(self, "queue_free")

func _on_Area2D_body_entered(body):
	if style == body.style:
		 return;
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(style)


func _on_Area2D_body_exited(body):
	if (style == Global.current_style): 
		return;
	if body.has_method('_on_Verse_Jump'):
		body._on_Verse_Jump(Global.current_style)
	if body.has_method('_on_Verse_Exit'):
		body._on_Verse_Exit(style)

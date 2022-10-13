extends Node2D


export var style = 0
var exploding = false
var dying = false
func _ready():
	if Global.portal != null:
		if Global.portal:
			Global.portal.self_destroy()
		Global.portal = self
	else:
		Global.portal = self
	$Sprite.set_material(load("res://arts/shaders/Portal%d.tres" % style))
	$Sprite/CPUParticles2D.set_material(load("res://arts/shaders/Style%d.tres" % style))
	set_scale(Vector2(0, 0))
	connect("tree_exiting", self, "global_cleanup")
	if not exploding:
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "scale", Vector2(1, 1), 1)
	else:
		verse_jump_explode()
	print(style)

func self_destroy():
	global_cleanup()
	exploding = true
	dying = true
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(0, 0), 0.5)
	tween.tween_callback(self, "queue_free")

func global_cleanup():
	if Global.portal == self:
		Global.portal = null
	
func _process(delta):
	if exploding and $Area2D.get_overlapping_bodies().size() > 0:
		if not dying:
			for i in $Area2D.get_overlapping_bodies():
				if i.style != style:
					i._on_Verse_Jump(style)
			
func verse_jump_explode():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2(10, 10), 0.6)
	
	tween.tween_callback(self, "verse_jump_end")

func verse_jump_end():
	Global.background._on_Verse_Jump(style)
	Global.current_style = style;
	queue_free()
	
func _on_Area2D_body_entered(body):
	if not exploding:
		if style == body.style:
			 return;
		var prev_style = body.style;
		if body.has_method('_on_Verse_Jump'):
			# jump to the verse style
			body._on_Verse_Jump(style)
		if body.has_method('_on_Verse_Exit'):
			# exit the current verse, and enter the new style
			body._on_Verse_Exit(prev_style, style)
	


func _on_Area2D_body_exited(body):
	if not exploding or dying:
#		if (style == Global.current_style): 
#			return;
		var prev_style = body.style;
		print("beg")
		print(prev_style, style,Global.current_style);
		if not 'dying' in body:
			if body.has_method('_on_Verse_Jump'):
				body._on_Verse_Jump(Global.current_style)
				
			if body.has_method('_on_Verse_Exit'):
				body._on_Verse_Exit(prev_style, Global.current_style)
		else:
			if not body.dying:
				if body.has_method('_on_Verse_Jump'):
					body._on_Verse_Jump(Global.current_style)
					
				if body.has_method('_on_Verse_Exit'):
					body._on_Verse_Exit(prev_style, Global.current_style)
			print("end")
			print(body.style, style, Global.current_style);

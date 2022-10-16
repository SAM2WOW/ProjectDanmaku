extends Node2D


export var style = 0
var exploding = false
var dying = false
var hurt_player = false;
var player_damage = Global.boss_stats[Global.difficulty]["transbullet explosion damage"];
var hurt_boss = false;
var duel_portal = false;
var portal_scale = Vector2(1.85, 1.85);

var smallparticle = preload("res://objects/VFX/small.tscn")

func _ready():
	
	if Global.portal != null:
		if Global.portal:
			Global.portal.self_destroy()
		Global.portal = self
	else:
		Global.portal = self
	$Sprite.set_material(load("res://arts/shaders/Portal%d.tres" % style))
	$Sprite/CPUParticles2D.set_material(load("res://arts/shaders/Style%d.tres" % style))
	$Sprite/CPUParticles2D2.set_material(load("res://arts/shaders/Style%d.tres" % style))
	set_scale(Vector2(0, 0))
	connect("tree_exiting", self, "global_cleanup")
	if not exploding:
		var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(self, "scale", portal_scale, 1)
		
		# $SpawnSound.play()
		
		yield(tween,"finished")
		$Sprite/CPUParticles2D.show()
		$Sprite/CPUParticles2D2.show()
	else:
		verse_jump_explode()
	#print(style)


func self_destroy():
	global_cleanup()
	$Sprite/CPUParticles2D.speed_scale = 3
	$Sprite/CPUParticles2D.set_emitting(false)
	$Sprite/CPUParticles2D.speed_scale = 3
	$Sprite/CPUParticles2D2.set_emitting(false)
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
			for body in $Area2D.get_overlapping_bodies():
				if body.style != style:
					var prev_style = body.style;
					# print("prev style: %d new style: %d" % [prev_style, style]);
					if (body.name == "Player" && hurt_player):
						Global.player.damage(player_damage);
						hurt_player = false;
					elif (body.name == "Boss" && hurt_boss):
						Global.boss.stunned = true;
						if (duel_portal):
							# 5 % of boss hp
							Global.boss.damage(Global.boss.max_hp*0.05);
							if Global.boss.stun_dur >= 10: 
								Global.boss.stun_dir = 7.5;
						else:
							# 2.5 % of boss hp
							Global.boss.damage(Global.boss.max_hp*0.025);
							Global.boss.stun_dur = Global.boss.stun_dur;
						hurt_boss = false;
						Global.boss.get_node("BrokeSfx").play();
						Global.camera.shake(0.6, 20, 10);
						print("boss is stunned!");
						
					if body.has_method('_on_Verse_Jump'):
						body._on_Verse_Jump(style)
					
					if body.has_method('_on_Verse_Exit'):
						body._on_Verse_Exit(prev_style, style)
				
func verse_jump_explode():
	if is_instance_valid(Global.boss):
		Global.new_style = style;
		Engine.set_time_scale(0.7)
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "scale", Vector2(8, 8), 0.8)
		tween.parallel().tween_property(Engine, "time_scale", 1.0, 0.8)
		
		# $SpawnSound.play()
		
		print("verse change");
		Global.boss.transbullet_cd = Global.boss.transbullet_max_cd;
		Global.boss.missed_bullet_counter = 0;
		Global.boss.transbullet_state = false
		Global.boss.last_trans_bullet = null;
		
		tween.tween_callback(self, "verse_jump_end")
		# scuffed way of playing a delayed sfx lmao
		yield(get_tree().create_timer(0.3), "timeout");
		SoundPlayer.play("VerseJump");
	


func verse_jump_end():
	Global.background._on_Verse_Jump(style)
	Global.current_style = style;
	Global.new_style = Global.current_style;
	queue_free()
	
func _on_Area2D_body_entered(body):
	if not exploding:
		if (body.name == "Boss"): return;
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
		if (style == Global.current_style): 
			return;
		var prev_style = style;
		
		var p = smallparticle.instance()
		p.set_global_position(body.get_global_position())
		p.style = style
		get_parent().add_child(p)
		p.look_at(get_global_position())

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


func _on_Area2D_area_entered(area):
	#print(area.name);
	if not exploding:
		if (area.name == "BossPortalBox"):
			if (Global.boss.style == style): return;
			Global.boss._on_Verse_Jump(style);
func _on_Area2D_area_exited(area):
	#print(area.name);
	if not exploding:
		if (area.name == "BossPortalBox"):
			if (Global.boss.style == Global.current_style): return;
			Global.boss._on_Verse_Jump(Global.current_style);
			

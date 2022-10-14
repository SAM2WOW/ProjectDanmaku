extends RigidBody2D

var style = 0;
var dir = Vector2();

# for detonation bullets
var health = 12
var moving = true
var damage = 1.0
var max_speed = 1000
var speed = 1000

var base_growth_rate = 0.01
var max_scale = 2.4
var max_scale_plus = 2.8
var damage_multiplier = 0.2

var portal = preload("res://objects/system/portal.tscn")
var dead = false
var hit = false
var hurt_player = false;
var next_scale = Vector2(0,0)

var growth_rate = 1
var start_protect = false

var dead_damp = 0.15
var init_size = 1
var duel_mode = false
export var tutorial_mode = false

func init_bullet():
	end_arrow()
	dead = false
	start_protect = true

	if is_instance_valid(Global.player):
		$area.look_at(Global.player.get_global_position())
	set_linear_velocity(Vector2(1000,100-randi() % 200).rotated($area.get_global_rotation()))
	self.connect("tree_exited", self, "boss_transState_cleanup")
	
func init_tutorial_bullet():
	end_arrow()
	dead = false
	start_protect = true
	max_scale = 4
	max_scale_plus = 3
	#set_linear_velocity(Vector2(1000,100-randi() % 200).rotated(get_global_rotation()))
	
func init_duel_bullet():
	end_arrow()
	dead = false
	start_protect = true

	$area.look_at(Global.player.get_global_position())
	health = 15
	max_scale = 4
	max_scale_plus = 4.2
	damage_multiplier = 0.1
	$area.set_scale(Vector2(2.2,2.2))
	set_linear_velocity(Vector2(500,100-randi() % 200).rotated($area.get_global_rotation()))
	
	start_protect = true
	
func ready_bullet():
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($area, "scale", Vector2(1.6, 1.6), 1)
	tween.tween_interval(0.2)
	tween.tween_callback(self, "init_bullet")

func ready_duel_bullet():
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($area, "scale", Vector2(2.5, 2.5), 2)
	$area/Node2D/Sprite2.modulate = Color('e00000')
	$arrows.modulate = Color('e00000')
	#tween.tween_callback(self, "init_duel_bullet")
	tween.tween_interval(0.3)
	tween.tween_callback(self, "init_duel_bullet")
	
func ready_tutorial_bullet():
	mode = MODE_STATIC
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($area, "scale", Vector2(3, 3), 1.5)
	$arrows.modulate = Color('ffffff')
	#tween.tween_callback(self, "init_duel_bullet")
	$area/CPUParticles2D4.one_shot = false
	tween.tween_interval(0.3)
	tween.tween_callback(self, "init_tutorial_bullet")
	
func boss_transState_cleanup():
	if is_instance_valid(Global.boss):
		Global.boss.transbullet_state = false
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _ready():
	self.connect("tree_exited", self, "boss_transState_cleanup")
	$area/CPUParticles2D4.set_emitting(true)
	$area/CPUParticles2D4.set_material(load("res://arts/shaders/Portal%d.tres" % style))
	$area/Node2D/Sprite.set_material(load("res://arts/shaders/Portal%d.tres" % style))
	dead = true
	if tutorial_mode:
		init_size = 3
		ready_tutorial_bullet()
	elif duel_mode:
		init_size = 2.4
		ready_duel_bullet()
	else:
		init_size =1.6
		ready_bullet()
	start_arrow()

	
func start_arrow():
	$arrows/Node2D2.ready_tween(init_size)
	$arrows/Node2D3.ready_tween(init_size)
	$arrows/Node2D4.ready_tween(init_size)
	$arrows/Node2D5.ready_tween(init_size)
func end_arrow():
	$arrows/Node2D2.end_tween()
	$arrows/Node2D3.end_tween()
	$arrows/Node2D4.end_tween()
	$arrows/Node2D5.end_tween()
	
func self_destroy():
	if duel_mode:
		verse_jump_init()
		return
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property($area, "scale", Vector2(0, 0), 0.2)
	if style != Global.current_style:
		spawn_portal()
	Global.boss.transbullet_state = false
	tween.tween_callback(self, "queue_free")

func spawn_portal():
	dead = true
	var p = portal.instance();
	#p.get_node("AnimatedSprite").play();
	p.style = style
	get_parent().add_child(p);
	p.set_global_position(get_global_position());
	p = load("res://objects/VFX/portalParticle.tscn").instance()
	p.set_global_position(get_global_position())
	p.style = style
	get_parent().add_child(p)
	
	#print(get_global_transform_with_canvas().origin)
	Global.console.play_shockwave_small(get_global_transform_with_canvas().origin,0.08)
	Global.boss.transbullet_state = false

func verse_jump_init():
	dead = true
	mode = MODE_STATIC
	#set_linear_velocity(Vector2(0,0))
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($area, "scale", Vector2(5, 5), 0.28)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($area, "scale", Vector2(5.2, 5.2), 0.1)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($area, "scale", Vector2(0, 0), 0.15)
	tween.tween_callback(self, "verse_jump_explode")

func bad_verse_jump_init():
	dead = true
	hurt_player = true;
	mode = MODE_STATIC
	$badParticle.set_emitting(true)
	$badParticle2.set_emitting(true)
	$area/CPUParticles2D4.set_emitting(false)
	#set_linear_velocity(Vector2(0,0))
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.tween_property($area, "scale", Vector2(1, 1), 0.28)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($area, "scale", Vector2(1.2, 1.2), 0.1)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($area, "scale", Vector2(0.8, 0.8), 0.15)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(self, "verse_jump_explode")
	$AnimationPlayer.play("glich")
	tween.tween_property($area, "scale", Vector2(0, 0), 0.3)
	tween.tween_callback(self, "queue_free")
	

# on portal bullet changing verses
func verse_jump_explode():
	$badParticle.set_emitting(false)
	if tutorial_mode:
		Global.console.start_game()
	var p = portal.instance();
	#p.get_node("AnimatedSprite").play();
	p.exploding = true
	p.style = style
	if (hurt_player): 
		p.hurt_player = true;
	get_parent().add_child(p);
	p.set_global_position(get_global_position());
	p.exploding = true
	if is_instance_valid(Global.boss):
		Global.boss.transbullet_state = false
		
	#print(p.get_global_transform_with_canvas().origin)
	Global.console.play_shockwave(get_global_transform_with_canvas().origin)
	
func _physics_process(delta):
	if not dead:
		if not hit:
			$area.scale = lerp($area.scale, Vector2(max_scale_plus,max_scale_plus),base_growth_rate * growth_rate)
			if $area.scale.x > max_scale:
				self_destroy()
				if duel_mode:
					bad_verse_jump_init()
	else:
		set_linear_velocity(lerp(get_linear_velocity(),Vector2.ZERO,dead_damp))

func _on_Verse_Jump(style):
	if style == self.style:
		queue_free()

func _on_hit(damage):
	if not hit:
		hit = true
		var damageTween = create_tween().set_trans(Tween.TRANS_CUBIC)
		damageTween.tween_property($area/Node2D, "scale", Vector2(1.3,1.3), 0.08)
		damageTween.parallel().tween_property($area/Node2D, "modulate", Color("ffafaf"), 0.08)
		damageTween.set_trans(Tween.TRANS_BACK)
		damageTween.set_ease(Tween.EASE_OUT)
		damageTween.tween_property($area/Node2D, "scale", Vector2(1.0,1.0), 0.08)
		damageTween.parallel().tween_property($area/Node2D, "modulate", Color("ffffff"), 0.08)
	
		yield(damageTween,"finished")
		hit = false

	


func damage(damage):
	if start_protect and not dead:
		damage = damage * damage_multiplier
		base_growth_rate = 0.01
		health -= damage
		if health > 6:
			if damage > 2:
				damage = 2
		if damage > 3:
			damage = 3
		elif damage < 1:
			damage = 0.8
		$Timer.start()
		#print('trans damage%d' % damage)
		_on_hit(damage)
		if $area.scale.x > 0.7:
			$area.scale -= Vector2(0.125,0.125) * damage
		
		
		if health <= 0:
			growth_rate = 0.5
			if duel_mode:
				growth_rate = 0.2
		if $area.scale.x < 1 and start_protect:
			if tutorial_mode:
				bad_verse_jump_init()
			else:
				verse_jump_init()
	


func _on_Timer_timeout():
	base_growth_rate += 0.003
	
func delayed_destroy():
	dead_damp = 0.05
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property($area, "scale", Vector2(0.7, 0.7), 1)
	yield(tween,"finished")
	self_destroy()


func _on_DetectionArea_body_entered(body):
	if not dead:
		if body == Global.player:
			if not tutorial_mode:
				body.damage(10)
				if duel_mode:
					bad_verse_jump_init()
					return
				#self_destroy()
				delayed_destroy()
				dead = true
		elif "Player" in body.name:
			if start_protect:
				damage(body.damage)
				#print(body)
				body._on_destroy()
				#body.queue_free()

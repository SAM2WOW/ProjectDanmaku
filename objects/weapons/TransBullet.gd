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

var portal = preload("res://objects/system/portal.tscn")
var dead = false
var hit = false
var next_scale = Vector2(0,0)

var damageTween

var growth_rate = 1
var start_protect = false

var dead_damp = 0.15

var duel_mode = false

func init_bullet():
	damageTween = create_tween().set_trans(Tween.TRANS_LINEAR)
	look_at(Global.player.get_global_position())
	set_linear_velocity(Vector2(1000,100-randi() % 200).rotated(get_global_rotation()))
	$area/Node2D/Sprite.set_material(load("res://arts/shaders/Portal%d.tres" % style))
	self.connect("tree_exited", self, "boss_transState_cleanup")
	
func init_duel_bullet():
	damageTween = create_tween().set_trans(Tween.TRANS_LINEAR)
	look_at(Global.player.get_global_position())
	set_linear_velocity(Vector2(1000,100-randi() % 200).rotated(get_global_rotation()))
	$area/Node2D/Sprite.set_material(load("res://arts/shaders/Portal%d.tres" % style))
	self.connect("tree_exited", self, "boss_transState_cleanup")

func boss_transState_cleanup():
	Global.boss.transbullet_state = false

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _ready():
	if Global.player:
		init_bullet()
	
func self_destroy():
	if (!is_instance_valid(Global.boss)): return;
	var tween = create_tween().set_trans(Tween.TRANS_BACK)
	tween.tween_property($area, "scale", Vector2(0, 0), 0.2)
	tween.tween_callback(self, "queue_free")
	if style != Global.current_style:
		spawn_portal()
	Global.boss.transbullet_state = false

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
	
func verse_jump_explode():
	var p = portal.instance();
	#p.get_node("AnimatedSprite").play();
	p.exploding = true
	p.style = style
	get_parent().add_child(p);
	p.set_global_position(get_global_position());
	p.exploding = true
	queue_free()
	Global.boss.transbullet_state = false
		
	print(p.get_global_transform_with_canvas().origin)
	Global.console.play_shockwave(get_global_transform_with_canvas().origin)
	
func _physics_process(delta):
	if not dead:
		if not hit:
			$area.scale = lerp($area.scale, Vector2(2.6,2.6),base_growth_rate * growth_rate)
			if $area.scale.x > 2.4:
				self_destroy()
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
	damage = damage * 0.1
	base_growth_rate = 0.01
	if damage > 4:
		damage = 4
	$Timer.start()
	print('trans damage%d' % damage)
	_on_hit(damage)
	if $area.scale.x > 0.7:
		$area.scale -= Vector2(0.15,0.15) * damage
	health -= 1 * damage
	
	
	if health <= 0:
		growth_rate = 0.5
	if $area.scale.x < 1 and start_protect:
		verse_jump_init()
	
	


func _on_Timer_timeout():
	base_growth_rate += 0.003
	start_protect = true
	
func delayed_destroy():
	dead_damp = 0.05
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property($area, "scale", Vector2(0.7, 0.7), 1)
	yield(tween,"finished")
	self_destroy()


func _on_DetectionArea_body_entered(body):
	if not dead:
		if body == Global.player:
			body.damage(10)
			#self_destroy()
			delayed_destroy()
			dead = true
		elif "Player" in body.name:
			if start_protect:
				damage(body.damage)
				#print(body)
				body._on_destroy()
				#body.queue_free()

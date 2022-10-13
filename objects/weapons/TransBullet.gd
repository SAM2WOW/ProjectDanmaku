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

var growth_rate = 1
var start_protect = false

var detect_failsafe = null

func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	style = _style;
	set_linear_velocity(Vector2(1000,0).rotated(dir))
	self.connect("tree_exited", self, "boss_transState_cleanup")

func boss_transState_cleanup():
	Global.boss.transbullet_state = false

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _ready():
	set_linear_velocity(Vector2(-1000,100-randi() % 200).rotated(get_global_rotation()))
	$area/Sprite.set_material(load("res://arts/shaders/Portal%d.tres" % style))

func self_destroy():
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
	
	print(get_global_transform_with_canvas().origin)
	Global.console.play_shockwave(get_global_transform_with_canvas().origin)
	

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
		
	print(get_global_transform_with_canvas().origin)
	Global.console.play_shockwave(get_global_transform_with_canvas().origin)
	
func _physics_process(delta):
	if not dead:
		$area.scale = lerp($area.scale, Vector2(2.5,2.5),base_growth_rate * growth_rate)
		if $area.scale.x > 2.4:
			self_destroy()
	else:
		set_linear_velocity(lerp(get_linear_velocity(),Vector2.ZERO,0.15))

func _on_Verse_Jump(style):
	if style == self.style:
		queue_free()


func damage(damage):
	damage = damage * 0.1
	base_growth_rate = 0.01
	if damage > 3:
		damage = 3
	$Timer.start()
	print('trans damage%d' % damage)
	if $area.scale.x > 0.7:
		$area.scale -= Vector2(0.12,0.12) * damage
		health -= 1 * damage

	if health <= 0:
		growth_rate = 0.5
	if $area.scale.x < 0.8 and start_protect:
		verse_jump_init()
	
	


func _on_Timer_timeout():
	base_growth_rate += 0.003
	start_protect = true
	


func _on_DetectionArea_body_entered(body):
	if not dead and start_protect:
		if body == Global.player:
			body.damage(10)
			self_destroy()
		elif "Player" in body.name:
			damage(body.damage)
			#print(body)
			body._on_destroy()
			#body.queue_free()

extends RigidBody2D

var style = 1
var dir = Vector2();

# for detonation bullets
var health = 12
var moving = true
var damage = 1.0
var max_speed = 1000
var speed = 1000

var portal = preload("res://objects/system/portal.tscn")
var dead = false

var growth_rate = 1

func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	style = _style;
	set_linear_velocity(Vector2(1000,0).rotated(dir))

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _ready():
	set_linear_velocity(Vector2(1000,100-randi() % 200).rotated(get_global_rotation()))

func spawn_portal():
	dead = true
	var p = portal.instance();
	#p.get_node("AnimatedSprite").play();
	p.style = style
	get_parent().add_child(p);
	p.set_global_position(get_global_position());
	queue_free()

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

func _physics_process(delta):
	if not dead:
		$area.scale = lerp($area.scale, Vector2(2.5,2.5),0.01 * growth_rate)
		if $area.scale.x > 2.4:
			spawn_portal()
	else:
		set_linear_velocity(lerp(get_linear_velocity(),Vector2.ZERO,0.15))

func _on_Area2D_body_entered(body):
	if not dead:
		if body == Global.player:
			body.damage(10)
			spawn_portal()
		if "PlayerBullet" in body.name:
			$area.scale -= Vector2(0.1,0.1)
			health -= 1
			if health <= 0:
				growth_rate = 0.5
			if $area.scale.x < 0.7:
				verse_jump_init()


extends RigidBody2D

var style = Global.initial_style
var basic_bullet = load("res://objects/weapons/BasicBullet.tscn");
var dir = Vector2();

# for detonation bullets
var detonate = false;
var detonate_at_pos = false;
var detonate_init_dist = Vector2.ZERO;
var detonate_pos = Vector2.ZERO;
var explosion = preload("res://objects/weapons/EnemyExplosion.tscn");

var damage = 1.0;


func init_bullet(_pos, _dir, _style):
	set_global_position(_pos);
	dir = _dir;
	set_bullet_rotation(_dir);
	style = _style;
	init_style(_style);

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Player" in body.name:
		body.damage(10)
		
		queue_free()

func show_verse_style(verse):
	get_node("Style%d" % style).show()
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()

func _on_Verse_Jump(verse):
	style = verse
	show_verse_style(verse);

func init_style(_style):
	style = _style;
	show_verse_style(_style);
	match _style:
		0:
			init_minimal_bullet();
		1:
			init_pixel_bullet();
		2:
			init_3d_bullet();
		3:
			init_collage_bullet();
		_:
			pass

# initialize the properties of these bullets
# minimal bullets have no real unique properties
func init_minimal_bullet():
	# ie.) init bullet properties
	damage = 1.0;

func init_pixel_bullet():
	pass

func init_3d_bullet():
	pass

func init_collage_bullet():
	pass
	
func set_bullet_rotation(_dir):
	rotation = 2*PI + atan2(_dir.y, _dir.x);
	
func set_detonate(dest=Global.player.get_global_position()):
	var pos = get_global_position();
	detonate_at_pos = true;
	detonate_pos = dest;
	detonate_init_dist =	sqrt(pow(dest.x-pos.x,2)+pow(dest.y-pos.y,2));

func explode():
	var e = explosion.instance();
	e.get_node("AnimatedSprite").play();
	get_parent().add_child(e);
	e.set_global_position(get_global_position());
	e.damage = damage;
	
func _physics_process(delta):
	if (detonate_at_pos):
		var speed = 1000; var base_speed = 100; var pos = get_global_position();
		
		var detonate_dist = sqrt(pow(detonate_pos.x-pos.x,2)+pow(detonate_pos.y-pos.y,2));
		var dist_ratio = detonate_dist/detonate_init_dist;
		set_linear_velocity(Vector2(
			dir.x*(base_speed+speed*dist_ratio), 
			dir.y*(base_speed+speed*dist_ratio)
		));
		if (dist_ratio < 0.01):
			explode();
			queue_free();


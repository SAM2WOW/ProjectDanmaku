extends RigidBody2D

var style = Global.initial_style
var damage = 10;
var dir = Vector2();
var bullet = load("res://objects/weapons/PlayerBullet.tscn");
var bullet_properties = Global.player_bullet_properties[style];
var explosion = preload("res://objects/weapons/PlayerExplosion.tscn");
var curr_vel = 0.0;

func _ready():
	pass;

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Bullet Collide %s" % body.name)
	if "Boss" in body.name:
		# spawns an explosion at collision area if pixel bullet
		if (style==1):
			var e = explosion.instance();
			e.get_node("AnimatedSprite").play();
			get_tree().root.add_child(e);
			e.set_global_position(get_global_position());
			e.damage = damage;
		else:
			body.damage(damage)
		
		queue_free()

func show_verse_style(verse):
	# show all the styles
	get_node("Style%d" % verse).show()
	# hide the styles that aren't said style
	for i in range(Global.total_style):
		if i != verse:
			get_node("Style%d" % i).hide()

func _on_ExplodeTimer_timeout():
	# queue_free();
	# var b = bullet.instance();
	print("explode!");

func _physics_process(delta):
	curr_vel = sqrt(pow(linear_velocity.x,2)+pow(linear_velocity.y,2));

# bursts after 1/2 way to dest perhaps
func pixel_verse_properties():
	pass;

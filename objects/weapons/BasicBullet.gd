extends RigidBody2D

var style = Global.initial_style
var basic_bullet = load("res://objects/weapons/BasicBullet.tscn");
var dir = Vector2();
var damage = 0.0;


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Player" in body.name:
		body.damage(10)
		
		queue_free()


func _on_Verse_Jump(verse):
	style = verse
	
	get_node("Style%d" % style).show()
	
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			#print("Style%d" % style)

# initialize the properties of these bullets
func init_minimal_bullet(verse):
	# ie.) init damage, speed, trajectory, etc: bullet properties of this verse
	pass

func init_pixel_bullet():
	pass

func init_3d_bullet():
	pass

func init_collage_bullet():
	pass
	
func fire_pulse(num, offset, style):
	var degrees = offset;
	var degree_inc = 360.0/num;
	for i in num:
		var b = basic_bullet.instance();
		var radians = degrees*PI/180;
		b.dir = Vector2(cos(radians), sin(radians));
		# b.bouncing = bouncing;
		# b.num_bounces = num_bounces;
		pass

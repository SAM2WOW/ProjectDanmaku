extends RigidBody2D

var style = Global.initial_style
var damage = 10;
var dir = Vector2();
var bullet = load("res://objects/weapons/PlayerBullet.tscn");

func _ready():
	pass;

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Boss" in body.name:
		body.damage(damage)
		
		queue_free()


func _on_Verse_Jump(verse):
	style = verse
	# show all the styles
	get_node("Style%d" % style).show()
	# hide the styles that aren't said style
	for i in range(Global.total_style):
		if i != style:
			get_node("Style%d" % i).hide()
			#print("Style%d" % style)

func _on_ExplodeTimer_timeout():
	# queue_free();
	# var b = bullet.instance();
	print("explode!");

func _physics_process(delta):
	pass;

# bursts after 1/2 way to dest perhaps
func pixel_verse_properties():
	pass;

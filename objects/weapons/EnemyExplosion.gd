extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var damage = 50;

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	# print(body.hit_by.find(self));
	print("Explosion Collide %s" % body.name)
	if ("Player" in body.name):
		body.damage(damage)

func _on_AnimatedSprite_animation_finished():
	# is_instance_valid()
	queue_free();

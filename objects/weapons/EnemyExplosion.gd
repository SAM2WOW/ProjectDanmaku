extends Area2D

var damage = 0.0;

func _on_Area2D_body_entered(body):
	# print(body.hit_by.find(self));
	#print("Explosion Collide %s" % body.name)
	if ("Player" in body.name):
		body.damage(damage)

func _on_AnimatedSprite_animation_finished():
	# is_instance_valid()
	queue_free();

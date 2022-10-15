extends Area2D


var damage = 0.0;
var charge = 0.0;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	scale = Vector2(1+charge, 1+charge);

func _on_Area2D_body_entered(body):
	# print(body.hit_by.find(self));
	#print("Explosion Collide %s" % body.name)
	if (("Boss" in body.name || "Enemy" in body.name) && body.hit_by.find(self) == -1):
		body.hit_by.append(self);
		body.damage(damage*(1+charge*0.75))
		# remove invalid instances from body
		for inst in body.hit_by:
			if !is_instance_valid(inst):
				body.hit_by.erase(inst);
	else:
		if body.get_collision_layer_bit(4):
			body.damage(damage*(1+charge*0.75))


func _on_AnimatedSprite_animation_finished():
	# is_instance_valid()
	queue_free();

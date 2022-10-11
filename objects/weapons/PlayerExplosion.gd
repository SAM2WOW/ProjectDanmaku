extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var active = true;
var damage = 20;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area2D_body_entered(body):
	# print(body.hit_by.find(self));
	print("Explosion Collide %s" % body.name)
	if (("Boss" in body.name || "Enemy" in body.name) && body.hit_by.find(self) == -1):
		body.hit_by.append(self);
		body.damage(damage)
		# remove invalid instances from body
		for inst in body.hit_by:
			if !is_instance_valid(inst):
				body.hit_by.erase(inst);


func _on_AnimatedSprite_animation_finished():
	# is_instance_valid()
	queue_free();

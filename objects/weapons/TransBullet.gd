extends RigidBody2D

var style = 0
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


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_PlayerBullet_body_entered(body):
	print("Collide %s" % body.name)
	if "Player" in body.name:
		body.damage(10)
		
		queue_free()


func bounce_bullet():
	if (get_global_position().y < -Global.window_height/2 || get_global_position().y >= Global.window_height/2):
		dir = Vector2(dir.x, -dir.y);
		set_linear_velocity(dir * get_linear_velocity());
		rotation = 2*PI + atan2(dir.y, dir.x);
	if (get_global_position().x < -Global.window_width/2 || get_global_position().x >= Global.window_width/2):
		dir = Vector2(-dir.x, dir.y);
		set_linear_velocity(dir * get_linear_velocity());
		rotation = 2*PI + atan2(dir.y, dir.x);


func set_bullet_rotation(_dir):
	rotation = 2*PI + atan2(_dir.y, _dir.x);


func explode():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	twee.tween_property


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
			explode;
			queue_free();


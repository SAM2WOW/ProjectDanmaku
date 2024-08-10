extends Node


var max_boss_health = 10000.0;
var boss_health = max_boss_health;
var portal
var play_time = 0.0
var gameover = false

var tutorial_bullet = preload("res://objects/weapons/TransBullet.tscn")
var portal_scene = preload("res://objects/system/portal.tscn")

var difficulty_bullets = [];
var game_started = false

func _ready():
	Global.console = self
	randomize()
	
	$"../CanvasLayer/Control/HealthBar".set_max(boss_health)
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
	
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("radius", 0.0)
	
	# init tutorial
	if not Global.tutorial_played:
		Global.tutorial_played = true
		Global.in_tutorial = true;
		$"../CanvasLayer/Control/Difficulties".show();
		for label in $"../CanvasLayer/Control/Difficulties".get_children():
			label.hide();
			label.modulate = Color(1, 1, 1, 0);
		yield(get_tree().create_timer(1), "timeout")
		for label in $"../CanvasLayer/Control/Difficulties".get_children():
			var twn = label.get_node("Tween");
			twn.interpolate_property(label, 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 1.5);
			twn.start();
			label.show();
			
		$"../CanvasLayer/Control/Tutorial".hide();
		$"../CanvasLayer/Control/Tutorial".modulate = Color(1, 1, 1, 0);
		$"../CanvasLayer/Control/Tutorial".get_node("Tween").interpolate_property($"../CanvasLayer/Control/Tutorial", 'modulate', Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_OUT);
		$"../CanvasLayer/Control/Tutorial".get_node("Tween").start();
		$"../CanvasLayer/Control/Tutorial".show();
		
		# var tutorial_spawn_locations = get_tree().get_nodes_in_group('difficulty_pos');
		var d = 0;
		for d_pos in get_parent().get_node("DifficultySpawnPos").get_children():
			var spawn_location = get_tree().get_nodes_in_group('difficulty_pos%d'%d);
			var t = tutorial_bullet.instance()
			t.tutorial_mode = true
			t.style = Global.initial_style;
			t.hurt_player = false;
			t.difficulty_style = d;
			$"../Node2D".add_child(t)
			t.set_global_position(spawn_location[0].get_global_position());
			difficulty_bullets.append(t);
			
			play_shockwave(t.get_global_transform_with_canvas().origin)
			d += 1;
		
		# $"../Node2D".add_child(t)
		# t.set_global_position(Vector2(0, -300))
		
		# play_shockwave(t.get_global_transform_with_canvas().origin)
	
	else:
		$"../CanvasLayer/Control/Tutorial".hide()
		$"../CanvasLayer/Control/Difficulties".hide();
		yield(get_tree().create_timer(0.2), "timeout")
		var t = portal_scene.instance()
		t.style = Global.initial_style;
		t.exploding = true
		t.hurt_player = false;
		$"../Node2D".add_child(t)
		t.set_global_position(Vector2(0, -300))
		
		play_shockwave(t.get_global_transform_with_canvas().origin)
		
		$"../CanvasLayer/Control/Tutorial".hide()
		start_game(Global.difficulty);


func _process(delta):
	if not gameover and is_instance_valid(Global.boss) && Global.boss.hp > 0:
		play_time += delta
		
		$"../CanvasLayer/Control/Timer".set_text("Time: %.2fs" % play_time)


func boss_dead():
	$"../CanvasLayer/Control/Gameover/CenterContainer/VBoxContainer/Time".set_text("Time: %.2fs" % play_time)
	$"../CanvasLayer/Control/Gameover".show()
	$"../CanvasLayer/Control/Gameover/CenterContainer/VBoxContainer/Restart".grab_focus()
	
	Global.player.health = 10000;
	Global.boss.dead = true;
	Global.boss.finish_attack();
	gameover = true
	Global.player.set_process(false)
	# Global.boss.set_process(false)
	# Global.boss.set_physics_process(false)
	


func player_dead():
	if gameover == false:
		$"../CanvasLayer/Control/PlayerDeath".show()
		$"../CanvasLayer/Control/PlayerDeath/CenterContainer/VBoxContainer/Restart".grab_focus()
		
		gameover = true
		Global.player.set_process(false)
		Global.player.set_physics_process(false)
		Global.boss.set_process(false)


func set_healthbar(boss_health):
		$"../CanvasLayer/Control/HealthBar".set_value(boss_health)


func play_shockwave(orgin, delay = 0):
	var h = orgin.x / $"../Node2D".get_viewport_rect().size.x
	var v = orgin.y / $"../Node2D".get_viewport_rect().size.y
	
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("center", Vector2(h, 1 - v))
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("strength", 0.05)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("width", 0.075)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("aberration", 0.3)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("feather", 0.1)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("radius", 0.0)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_interval(delay)
	tween.tween_property($"../CanvasLayer/Control/Shockwave".get_material(), "shader_param/radius", 1.7, 0.8)


func play_shockwave_small(orgin, delay = 0):
	var h = orgin.x / $"../Node2D".get_viewport_rect().size.x
	var v = orgin.y / $"../Node2D".get_viewport_rect().size.y
	
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("center", Vector2(h, 1 - v))
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("strength", 0.035)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("width", 0.018)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("aberration", 0.28)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("feather", 0.12)
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("radius", 0.0)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(delay)
	tween.tween_property($"../CanvasLayer/Control/Shockwave".get_material(), "shader_param/radius", 1.5, 1.5)
	
	#yield(tween, "finished")
	#$"../CanvasLayer/Control/Shockwave".hide()

#set difficulty is immediatly called when the selection bullet is destroyed
func set_difficulty(_difficulty):
	Global.difficulty = _difficulty;
	if (Global.in_tutorial):
		for d in difficulty_bullets:
			if d.difficulty_style != _difficulty:
				d.dead = true
				var d_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				d_tween.tween_property(d.get_node("area"), "scale", Vector2(0, 0), 0.3)
				d_tween.tween_callback(d, "queue_free")
	var dif_track =0
	for label in $"../CanvasLayer/Control/Difficulties".get_children():
		if _difficulty != dif_track:
			var twn = create_tween().set_trans(Tween.TRANS_CUBIC)
			twn.tween_property(label, "modulate", Color(255,255,255,0), 0.3)
			twn.tween_callback(label, "hide")
		dif_track +=1
	print("difficulty: ", _difficulty);

func start_game(_difficulty):
	
	if (is_instance_valid(Global.player)):
		Global.player.init_difficulty(_difficulty);
	#function moved to set_difficulty()
	
#	Global.difficulty = _difficulty;
#	if (is_instance_valid(Global.player)):
#		Global.player.init_difficulty(_difficulty);
#	if (Global.in_tutorial):
#		for d in difficulty_bullets:
#			if d.difficulty_style != _difficulty:
#				var d_tween = create_tween().set_trans(Tween.TRANS_BACK)
#				d_tween.tween_property(d.get_node("area"), "scale", Vector2(0, 0), 0.2)
#				d_tween.tween_callback(d, "queue_free")
#	print("difficulty: ", _difficulty);
	var b = load("res://objects/characters/Boss.tscn").instance()
	$"../CanvasLayer/Control/HealthBar".set_max(b.max_hp)
	$"../CanvasLayer/Control/HealthBar".set_value(b.max_hp)
	Global.in_tutorial = false;
	b.style = Global.tutorial_style;
	b.set_global_position(Vector2(0, -300))
	
	#get_node('../Node2D').add_child(b)
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	#tween.tween_property($"../Node2D/Background", "modulate", Color.white, 0.7)
	tween.tween_interval(0.45)
	tween.parallel().tween_property($"../CanvasLayer/Control/Tutorial", "modulate", Color("00ffffff"), 0.4)
	tween.parallel().tween_property($"../CanvasLayer/Control/Difficulties", "modulate", Color("00ffffff"), 0.4)
	tween.parallel().tween_property($"../CanvasLayer/Control/HealthBar", "modulate", Color.white, 0.4)
	tween.parallel().tween_property($"../CanvasLayer/Control/Timer", "modulate", Color.white, 0.4)
	
	yield(tween, "finished")
	get_node('../Node2D').add_child(b)
	game_started = true
	tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.1)
	tween.tween_property($"../Node2D/Background", "modulate", Color.white, 0.2)
	tween.tween_property($"../CanvasLayer/Control/HealthBar", "rect_size", Vector2($"../CanvasLayer/Control/HealthBar".get_size().x, 30), 0.5)
	tween.parallel().tween_property($"../CanvasLayer/Control/HealthBar/Label", "rect_size", Vector2($"../CanvasLayer/Control/HealthBar/Label".get_size().x, 30), 0.5)
	
	MusicPlayer.play_music()
	MusicPlayer.fade_in()
	
	yield(tween, "finished")
	
	$"../CanvasLayer/Control/Tutorial".hide()
	$"../CanvasLayer/Control/Difficulties".hide();

func _on_Restart_pressed():
	get_tree().set_pause(false)
	Global.current_style = Global.initial_style
	get_tree().reload_current_scene()


func _on_DifficultySelect_pressed():
	Global.tutorial_played = false;
	get_tree().set_pause(false)
	MusicPlayer.fade_out(true);
	get_tree().reload_current_scene()
	# tween.tween_callback(self, "queue_free")

extends Node


var max_boss_health = 10000.0;
var boss_health =  max_boss_health;
var portal
var play_time = 0.0
var gameover = false

var tutorial_bullet = preload("res://objects/weapons/TransBullet.tscn")
var portal_scene = preload("res://objects/system/portal.tscn")

func _ready():
	Global.console = self
	randomize()
	
	$"../CanvasLayer/Control/HealthBar".set_max(boss_health)
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
	
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("radius", 0.0)
	
	if not Global.tutorial_played:
		Global.tutorial_played = true
		
		yield(get_tree().create_timer(1), "timeout")
		
		var t = tutorial_bullet.instance()
		t.tutorial_mode = true
		t.style = 1
		t.hurt_player = false;
		$"../Node2D".add_child(t)
		t.set_global_position(Vector2(0, -300))
		
		play_shockwave(t.get_global_transform_with_canvas().origin)
	
	else:
		$"../CanvasLayer/Control/Tutorial".hide()
		
		yield(get_tree().create_timer(0.2), "timeout")
		var t = portal_scene.instance()
		t.style = 1
		t.exploding = true
		t.hurt_player = false;
		$"../Node2D".add_child(t)
		t.set_global_position(Vector2(0, -300))
		
		play_shockwave(t.get_global_transform_with_canvas().origin)
		
		$"../CanvasLayer/Control/Tutorial".hide()
		start_game()


func _process(delta):
	if boss_health > 0:
		play_time += delta


func boss_dead():
	$"../CanvasLayer/Control/Gameover/CenterContainer/VBoxContainer/Time".set_text("Time: %.2fs" % play_time)
	$"../CanvasLayer/Control/Gameover".show()


func player_dead():
	if gameover == false:
		$"../CanvasLayer/Control/PlayerDeath".show()
		
		gameover = true
		Global.player.set_process(false)
		Global.player.set_physics_process(false)
		Global.boss.set_process(false)


func damage_boss(amount):
	if gameover == false:
		boss_health -= amount
		
		$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
		
		if boss_health <= 0:
			boss_dead()
			
			gameover = true
			Global.player.set_process(false)
			Global.boss.set_process(false)
			Global.boss.set_physics_process(false)


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

func start_game():
	var b = load("res://objects/characters/Boss.tscn").instance()
	b.style = 1
	get_node('../Node2D').add_child(b)
	b.set_global_position(Vector2(0, -300))
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($"../Node2D/Background", "modulate", Color.white, 0.7)
	tween.parallel().tween_property($"../CanvasLayer/Control/Tutorial", "modulate", Color("00ffffff"), 0.4)
	tween.parallel().tween_property($"../CanvasLayer/Control/HealthBar", "modulate", Color.white, 0.4)
	tween.tween_property($"../CanvasLayer/Control/HealthBar", "rect_size", Vector2($"../CanvasLayer/Control/HealthBar".get_size().x, 14), 0.5)
	
	MusicPlayer.play_music()
	MusicPlayer.fade_in()
	
	yield(tween, "finished")
	$"../CanvasLayer/Control/Tutorial".hide()

func _on_Restart_pressed():
	get_tree().set_pause(false)
	Global.current_style = Global.initial_style
	get_tree().reload_current_scene()

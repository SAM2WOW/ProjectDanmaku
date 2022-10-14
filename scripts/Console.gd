extends Node


var boss_health = 5000
var portal
var play_time = 0.0


func _ready():
	Global.console = self
	
	$"../CanvasLayer/Control/HealthBar".set_max(boss_health)
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)


func _process(delta):
	if boss_health > 0:
		play_time += delta


func boss_dead():
	$"../CanvasLayer/Control/Gameover/CenterContainer/VBoxContainer/Time".set_text("Time: %.2fs" % play_time)
	$"../CanvasLayer/Control/Gameover".show()


func player_dead():
	$"../CanvasLayer/Control/PlayerDeath".show()
	Global.player.set_process(false)
	Global.boss.set_process(false)
	
	get_tree().set_pause(true)


func damage_boss(amount):
	boss_health -= amount
	
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
	
	if boss_health <= 0:
		boss_dead()
		
		Global.player.set_process(false)
		Global.boss.set_process(false)
		
		get_tree().set_pause(true)


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
	tween.tween_property($"../CanvasLayer/Control/Shockwave".get_material(), "shader_param/radius", 1.7, 1)

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


func _on_Restart_pressed():
	get_tree().set_pause(false)
	Global.current_style = Global.initial_style
	get_tree().reload_current_scene()

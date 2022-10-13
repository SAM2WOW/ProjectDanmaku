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


func damage_boss(amount):
	boss_health -= amount
	
	$"../CanvasLayer/Control/HealthBar".set_value(boss_health)
	
	if boss_health <= 0:
		boss_dead()
		Global.boss.queue_free()
		
		Global.player.set_process(false)


func play_shockwave(orgin):
	var h = orgin.x / $"../Node2D".get_viewport_rect().size.x
	var v = orgin.y / $"../Node2D".get_viewport_rect().size.y
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("center", Vector2(h, 1 - v))
	
	$"../CanvasLayer/Control/Shockwave".get_material().set_shader_param("radius", 0.0)
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($"../CanvasLayer/Control/Shockwave".get_material(), "shader_param/radius", 2.0, 2)
	
	#yield(tween, "finished")
	#$"../CanvasLayer/Control/Shockwave".hide()


func _on_Restart_pressed():
	Global.current_style = Global.initial_style
	get_tree().reload_current_scene()

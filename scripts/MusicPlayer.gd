extends Node

var default_volume = -10.0

var song1 = preload("res://sounds/bgm.ogg")
var song2 = preload("res://sounds/bgm_dim.ogg")

var tween

func _ready():
	# dynamically download music for HTML5
	
	var a = AudioStreamPlayer.new()
	var b = AudioStreamPlayer.new()
	
	a.set_stream(song1)
	a.set_volume_db(-80.0)
	a.set_bus("Music")
	a.set_name("BGM")
	add_child(a)

	b.set_stream(song2)
	b.set_volume_db(-80.0)
	b.set_bus("Music")
	b.set_name("BGM2")
	add_child(b)
	

func play_music():
	if not $BGM.is_playing():
		$BGM.play()
		$BGM2.play()


func stop_music():
	$BGM.stop();
	$BGM2.stop();


func fade_in():
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property($BGM, "volume_db", default_volume, 0.3)


func fade_out(stop=false):
	if tween:
		tween.kill()
		
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($BGM, "volume_db", -80.0, 3)
	tween.parallel().tween_property($BGM2, "volume_db", -80.0, 3)
	
	tween.tween_callback(self, "stop_music")



func dim():
	print('DIM AUDIO')
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($BGM, "volume_db", -80.0, 0.5)
	tween.parallel().tween_property($BGM2, "volume_db", default_volume, 0.5)


func undim():
	if tween:
		tween.kill()
	
	tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($BGM, "volume_db", default_volume, 0.5)
	tween.parallel().tween_property($BGM2, "volume_db", -80.0, 0.5)


extends Node

var default_volume = -5

var song1 = preload("res://sounds/bgm.ogg")
var playlist = [song1]
var last_played 


func _ready():
	# dynamically download music for HTML5
	
	var a = AudioStreamPlayer.new()
	
	# pick a random song
	randomize()
	last_played = randi() % playlist.size()
	a.set_stream(playlist[last_played])
	
	a.set_volume_db(-80)
	a.set_bus("Music")
	a.set_autoplay(true)
	a.set_name("BGM")
	#a.connect("finished", self, "_on_finished")
	add_child(a)
	
	var t = Tween.new()
	t.set_name("Tween")
	add_child(t)


func _on_finished():
	# non repeating random playlist
	var next = randi() % playlist.size()
	while next == last_played:
		next = randi() % playlist.size()
	
	$BGM.set_stream(playlist[next])
	$BGM.play()


func fade_in():
	var tween = get_node("Tween")
	tween.interpolate_property($BGM, "volume_db",
			-80, default_volume, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func fade_out():
	var tween = get_node("Tween")
	tween.interpolate_property($BGM, "volume_db",
			default_volume, -80, 1,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

extends Node


var sounds = {
	"Next": "next_sfx.mp3",
	"Home": "home.mp3",
	"Back": "back.mp3",
}


func _ready():
	for i in sounds.keys():
		var s = AudioStreamPlayer.new()
		s.set_stream(load("res://sounds/%s" % sounds[i]))
		s.set_bus("Sound")
		s.name = i
		add_child(s)


func play(sound_name):
	get_node(sound_name).play()

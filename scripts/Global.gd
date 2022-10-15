extends Node


var console
var player
var boss
var camera
var background
var portal

var tutorial_played = false

var tutorial_style = 0;
var initial_style = 1
var in_tutorial = true;
var total_style = 4
var current_style = initial_style
var new_style = current_style;

var window_width = ProjectSettings.get_setting("display/window/size/width");
var window_height = ProjectSettings.get_setting("display/window/size/height");


var player_bullet_properties = {
	0: {"damage":15, "fire rate":0.25, "speed":900},
	1: {"damage":50, "fire rate":0.6, "speed":1750},
	2: {"damage":40, "fire rate":0.6, "speed":900},
	3: {"damage":15, "fire rate":0.4, "speed":1000}
}

var boss_patterns = {
	0: {
		0: {"waves":4, "interval":0.3},
		1: {"waves":3, "interval":0.6}
	},
	1: {
		0: {"waves": 6, "interval": 0.3},
		1: {"waves": 8, "interval": 0.1}
	},
	2: {
		0: {"waves": 2, "interval": 1.5},
		1: {"waves": 6, "interval": 0.5}
	},
	3: {
		0: {"waves": 3, "interval": 0.6},
		1: {"waves": 2, "interval": 0.3}
	}
}

var boss_bullet_properties = {
	0: {"damage": 30, "speed": 300},
	1: {"damage": 40, "speed": 1000},
	2: {"damage": 20, "speed": 0},
	3: {"damage": 20, "speed": 300}
}

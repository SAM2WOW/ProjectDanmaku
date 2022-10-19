extends Node


var console
var player
var boss
var camera
var background
var portal

var tutorial_played = false

var num_difficulties = 3;
var difficulty = 0; # 0 is easy, 1 is medium, 2 is hard
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
	1: {"damage":50, "fire rate":0.5, "speed":1750},
	2: {"damage":50, "fire rate":0.6, "speed":1750},
	3: {"damage":20, "fire rate":0.4, "speed":1000}
}
var player_stats = {
	0: {
		"hp": 100.0,
		"move speed": 400.0,
		"hp regen": 3
	},
	1: {
		"hp": 100.0,
		"move speed": 400.0,
		"hp regen": 2
	},
	2: {
		"hp": 100.0,
		"move speed": 400.0,
		"hp regen": 1
	}
}

var boss_stats = {
	0: {
		"hp": 8500.0,
		"speed": 150,
		"movement interval": 8.0,
		"attack interval": 2.0,
		"trans bullet cd": 2,
		"missed bullet cd": 5,
		"stun duration": 5,
		"transbullet damage": 20,
		"transbullet explosion damage": 20
	},
	1: {
		"hp": 6000.0,
		"speed": 150,
		"movement interval": 7.0,
		"attack interval": 1.0,
		"trans bullet cd": 2,
		"missed bullet cd": 2,
		"stun duration": 3,
		"transbullet player damage": 20,
		"transbullet damage": 30,
		"transbullet explosion damage": 35
	},
	2: {
		"hp": 17500.0,
		"speed": 300,
		"movement interval": 4.0,
		"attack interval": 0.75,
		"trans bullet cd": 3,
		"missed bullet cd": 3,
		"stun duration": 2,
		"transbullet damage": 30,
		"transbullet explosion damage": 60
	}
}

var boss_bullet_properties = {
	0: {
		0: {"damage": 10, "speed": 250},
		1: {"damage": 20, "speed": 750},
		2: {"damage": 15, "speed": 300},
		3: {"damage": 5, "speed": 200}
	},
	1: {
		0: {"damage": 30, "speed": 300},
		1: {"damage": 40, "speed": 1000},
		2: {"damage": 35, "speed": 300},
		3: {"damage": 20, "speed": 300}
	},
	2: {
		0: {"damage": 40, "speed": 400},
		1: {"damage": 50, "speed": 1250},
		2: {"damage": 50, "speed": 300},
		3: {"damage": 20, "speed": 350}
	}
}

var boss_patterns = {
	0: {
		0: {
			0: {"waves":3, "interval":0.5},
			1: {"waves":2, "interval":0.8}
		},
		1: {
			0: {"waves": 4, "interval": 0.5},
			1: {"waves": 6, "interval": 0.2}
		},
		2: {
			0: {"waves": 2, "interval": 2.2},
			1: {"waves": 4, "interval": 0.8}
		},
		3: {
			0: {"waves": 3, "interval": 0.6},
			1: {"waves": 2, "interval": 0.3}
		}
	},
	1: {
		0: {
			0: {"waves":4, "interval":0.3},
			1: {"waves":3, "interval":0.6}
		},
		1: {
			0: {"waves": 6, "interval": 0.3},
			1: {"waves": 8, "interval": 0.1}
		},
		2: {
			0: {"waves": 3, "interval": 1.5},
			1: {"waves": 6, "interval": 0.35}
		},
		3: {
			0: {"waves": 3, "interval": 0.6},
			1: {"waves": 2, "interval": 0.3}
		}
	},
	2: {
		0: {
			0: {"waves":5, "interval":0.2},
			1: {"waves":4, "interval":0.4}
		},
		1: {
			0: {"waves": 8, "interval": 0.1},
			1: {"waves": 12, "interval": 0.1}
		},
		2: {
			0: {"waves": 5, "interval": 0.85},
			1: {"waves": 10, "interval": 0.2}
		},
		3: {
			0: {"waves": 4, "interval": 0.5},
			1: {"waves": 2, "interval": 0.2}
		}
	}
}

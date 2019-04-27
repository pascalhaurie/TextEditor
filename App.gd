extends Node

var app_name = "TextEdit"
var current_file = "Untitled"

const FILE_MENU_OPTIONS = ["New","Open","Save","Save As","Exit"]
const EDIT_MENU_OPTIONS = ["To Be Filled..."]
const OPTIONS_MENU_OPTIONS = ["Show Line Numbers","Enable Word Wrap"]

var show_line_numbers = false
var enable_word_wrap = false

var current_theme = "White Theme"

# Called when the node enters the scene tree for the first time.
func _ready():
	update_window_title()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_window_title():
	OS.set_window_title(app_name + " | " + current_file)
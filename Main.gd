extends Control

onready var file_menu = $TopBar/MenuBar/FileMenu
onready var edit_menu = $TopBar/MenuBar/EditMenu
onready var options_menu = $TopBar/MenuBar/OptionsMenu
onready var theme_menu = $TopBar/MenuBar/ThemeMenu
onready var help_menu = $TopBar/MenuBar/HelpMenu

onready var open_file_window = $OpenFileDialog
onready var save_file_window = $SaveFileDialog
onready var about_menu_window = $AboutMenuDialog

onready var tabs = $MiddleBar/Tabs
onready var text_edit = $MiddleBar/TextEdit

onready var letter_count = $BottomBar/HBoxContainer/LetterCount
onready var line_count = $BottomBar/HBoxContainer/LineCount

var file_popup = null
var edit_popup = null
var options_popup = null
var theme_popup = null
var help_popup = null

var tab_count_id = 0
var current_tab = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$OpenFileDialog.set_filters(PoolStringArray(["*.txt ; Text Document","*.html ; Hyper Text Markup Lang.", "*.css ; Cascading Style Sheets", "*.php : PHP"]))
	tabs.set_select_with_rmb(true)
	
	populate_file_menu()
	populate_edit_menu()
	populate_options_menu()
	populate_theme_menu()
	populate_help_menu()
	
	update_editor_tabs()
	update_text_stats()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func populate_file_menu():
	file_popup = file_menu.get_popup()
	file_popup.connect("id_pressed", self, "_on_file_menu_item_pressed")
	
	for i in App.FILE_MENU_OPTIONS:
		file_popup.add_item(i)
	
	file_popup.rect_min_size = Vector2(200, 30)
	#file_popup.set_item_shortcut(0, menu_shortcut(KEY_N))
	#file_popup.set_item_shortcut(1, menu_shortcut(KEY_O))

func populate_edit_menu():
	edit_popup = edit_menu.get_popup()
	edit_popup.connect("id_pressed", self, "_on_edit_menu_item_pressed")
	
	for i in App.EDIT_MENU_OPTIONS:
		edit_popup.add_item(i)
	
	edit_popup.rect_min_size = Vector2(200, 30)

func populate_options_menu():
	options_popup = options_menu.get_popup()
	
	options_popup.connect("id_pressed", self, "_on_options_menu_item_pressed")
	
	options_popup.add_check_item("Show Line Numbers", 0)
	options_popup.set_item_checked(0, text_edit.show_line_numbers)
	
	options_popup.add_check_item("Word Wrap", 1)
	options_popup.set_item_checked(0, text_edit.wrap_enabled)
	
	options_popup.rect_min_size = Vector2(200, 30)

func populate_theme_menu():
	theme_popup = theme_menu.get_popup()
	theme_popup.connect("id_pressed", self, "_on_theme_menu_item_pressed")
	
	theme_popup.add_check_item("White Theme", 0)
	if App.current_theme == "White Theme":
		theme_popup.set_item_checked(0, true)
	else:
		theme_popup.set_item_checked(0, false)
	
	theme_popup.add_check_item("Grey Theme", 1)
	if App.current_theme == "Grey Theme":
		theme_popup.set_item_checked(1, true)
	else:
		theme_popup.set_item_checked(1, false)
	
	theme_popup.rect_min_size = Vector2(200, 30)

func populate_help_menu():
	help_popup = help_menu.get_popup()
	help_popup.connect("id_pressed", self, "_on_about_menu_item_pressed")
	
	help_popup.add_item("About", 0)
	
	help_popup.rect_min_size = Vector2(200, 30)

func new_file():
	text_edit.text = ""
	App.current_file = "Untitled"
	App.update_window_title()
	$BottomBar/LineCount.text = "Lines: " + str(text_edit.get_line_count())

func save_file():
	var path = App.current_file
	if path == "Untitled":
		save_file_window.popup()
		
	else:
		var file = File.new()
		file.open(path, 2)
		file.store_string(get_node("MiddleBar/Untitled"+str(current_tab)).text)
		file.close()

func open_file():
	open_file_window.popup()

func menu_shortcut(key):
	var shortcut = ShortCut.new()
	var inputevent = InputEventKey.new()
	
	inputevent.set_scancode(key)
	inputevent.control = true
	
	shortcut.set_shortcut(inputevent)
	return shortcut

func update_editor_tabs():
	if tabs.get_tab_count() == 0:
		var path = App.current_file
		if path == "Untitled":
			create_new_tab("Untitled", tab_count_id)

func create_new_tab(tab_title, tab_id):
	var new_text_edit = text_edit.duplicate()
	new_text_edit.name = str(tab_title,tab_id)
	#new_text_edit.rect_size = Vector2(1014, 500)
	
	tabs.add_tab(tab_title)
	$MiddleBar.add_child(new_text_edit)
	new_text_edit.show()
	update_editor()

func change_tab(tab_id):
	var new_tab = tab_id
	
	if get_node("MiddleBar/Untitled"+str(current_tab)) != null:
		get_node("MiddleBar/Untitled"+str(current_tab)).hide()
	
	get_node("MiddleBar/Untitled"+str(new_tab)).show()
	current_tab = tab_id
	update_editor()

func update_editor():
	for i in tabs.get_tab_count():
		get_node("MiddleBar/Untitled"+str(i)).show_line_numbers = App.show_line_numbers
		get_node("MiddleBar/Untitled"+str(i)).wrap_enabled = App.enable_word_wrap

func update_text_stats():
	letter_count.text = "Characters: " + str(get_node("MiddleBar/Untitled"+str(tabs.get_current_tab())).text.length())
	line_count.text = "Lines: " + str(get_node("MiddleBar/Untitled"+str(tabs.get_current_tab())).get_line_count())

func _on_file_menu_item_pressed(id):
	match id:
		0:
			new_file()
		1:
			open_file_window.popup()
		2:
			save_file()
		3:
			save_file_window.popup()
		4:
			get_tree().quit()

func _on_edit_menu_item_pressed(id):
	match id:
		0:
			pass

func _on_options_menu_item_pressed(id):
	match id:
		0:
			App.show_line_numbers = !App.show_line_numbers
			update_editor()
		1:
			App.enable_word_wrap = !App.enable_word_wrap
			update_editor()
	
	options_popup.set_item_checked(0, App.show_line_numbers)
	options_popup.set_item_checked(1, App.enable_word_wrap)

func _on_theme_menu_item_pressed(id):
	match id:
		0:
			App.current_theme = "White Theme"
			$"/root/Main".theme = load("res://themes/White_Theme.tres")
			theme_popup.set_item_checked(0, true)
			theme_popup.set_item_checked(1, false)
		1:
			App.current_theme = "Grey Theme"
			$"/root/Main".theme = load("res://themes/Grey_Theme.tres")
			theme_popup.set_item_checked(0, false)
			theme_popup.set_item_checked(1, true)

func _on_about_menu_item_pressed(id):
	match id:
		0:
			about_menu_window.popup()
		1:
			pass

func _on_OpenFileDialog_file_selected(path):
	var file = File.new()
	file.open(path, 1)
	text_edit.text = file.get_as_text()
	file.close()
	App.current_file = path
	App.update_window_title()
	$BottomBar/LineCount.text = "Lines: " + str(text_edit.get_line_count())

func _on_SaveFileDialog_file_selected(path):
	var file = File.new()
	file.open(path, 2)
	file.store_string(get_node("MiddleBar/Untitled"+str(current_tab)).text)
	file.close()

func _on_NewTabButton_pressed():
	tab_count_id += 1
	create_new_tab("Untitled", tab_count_id)
	get_node("MiddleBar/Untitled"+str(tab_count_id)).show()
	tabs.current_tab = tab_count_id

func _on_Tabs_tab_clicked(tab):
	change_tab(tab)

func _on_Tabs_tab_hover(tab):
	current_tab = tabs.get_current_tab()

func _on_Tabs_tab_changed(tab):
	update_text_stats()

func _on_Tabs_tab_close(tab):
	if tab_count_id == 0:
		get_node("MiddleBar/Untitled"+str(tab_count_id)).select_all()
		get_node("MiddleBar/Untitled"+str(tab_count_id)).cut()
		
	else:
		get_node("MiddleBar/Untitled"+str(tab)).queue_free()
		tabs.remove_tab(tab)
		tab_count_id -= 1
		
		get_node("MiddleBar/Untitled"+str(tab_count_id)).show()

func _on_TextEdit_text_changed():
	update_text_stats()

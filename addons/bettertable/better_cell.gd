extends LineEdit

const BetterCell := preload("res://addons/bettertable/better_cell.gd")

signal double_clicked(cell:BetterCell)
signal right_clicked(cell:BetterCell)

var _double_click_action_name := "cell_double_left_click"
var _right_click_action_name := "cell_right_click"

var row_idx:int
var col_idx:int

func _init(_row_idx:int, _col_idx:int, _text:String) -> void:
	selecting_enabled = false
	editable = false
	row_idx = _row_idx
	col_idx = _col_idx
	text = _text
	context_menu_enabled = false

	if not InputMap.has_action(_double_click_action_name):
		var action := InputEventMouseButton.new()
		action.button_index = MOUSE_BUTTON_LEFT
		action.double_click = true
		InputMap.add_action(_double_click_action_name)
		InputMap.action_add_event(_double_click_action_name, action)
	if not InputMap.has_action(_right_click_action_name):
		var action := InputEventMouseButton.new()
		action.button_index = MOUSE_BUTTON_RIGHT
		InputMap.add_action(_right_click_action_name)
		InputMap.action_add_event(_right_click_action_name, action)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action(_double_click_action_name) and event.double_click:
			double_clicked.emit(self)
		elif event.is_action(_right_click_action_name):
			right_clicked.emit(self)

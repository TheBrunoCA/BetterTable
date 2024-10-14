@tool
extends PanelContainer
class_name BetterTable

const BetterCell := preload("res://addons/bettertable/better_cell.gd")
const BetterColumn := preload("res://addons/bettertable/better_column.gd")

#region Signals
signal row_double_clicked(row_dict:Dictionary)
signal row_right_clicked(row_dict:Dictionary)
signal data_source_changed
#endregion

#region Themes
@export_group("Themes")
@export var _mock_table:bool = false:
	get: return _mock_table
	set(value):
		_mock_table = value
		_enable_mock_table(value)
@export var _mock_data_count:int = 200
@export var _panel_container_theme:Theme:
	get: return theme
	set(value): theme = value
@export var _margin_container_theme:Theme:
	get: return _mc.theme
	set(value): _mc.theme = value
@export var _scroll_container_theme:Theme:
	get: return _sc.theme
	set(value): _sc.theme = value
@export var _vbox_container_theme:Theme:
	get: return _vbc.theme
	set(value): _vbc.theme = value
@export var _header_button_theme:Theme:
	get: return _header_button_theme
	set(value):
		_header_button_theme = value
		_update_headers_buttons_theme()
@export var _cell_line_edit_theme:Theme:
	get: return _cell_line_edit_theme
	set(value):
		_cell_line_edit_theme = value
		_update_cells_line_edit_theme()
@export var _columns_hsplit_theme:Theme:
	get: return _columns_hsplit_theme
	set(value):
		_columns_hsplit_theme = value
		_update_column_hplit_theme()
#endregion

#region Themes callbacks
func _enable_mock_table(state:bool) -> void:
	if state:
		var mock_data:Array[Dictionary]
		for i in range(0, _mock_data_count):
			var dict := {ID=i, DESCRIPTION="MockDescription"+str(i), CATEGORY="MockCategory"+str(i)}
			mock_data.append(dict)
		included_fields = ["ID", "DESCRIPTION", "CATEGORY"]
		data_source = mock_data
		return
	_clear_columns()
	included_fields = []
	data_source = []

func _update_headers_buttons_theme() -> void:
	if _columns_nodes.is_empty(): return
	for column in _columns_nodes:
		if column._vbc.get_child_count() <= 0: continue
		column._vbc.get_child(0).theme = _header_button_theme

func _update_column_hplit_theme() -> void:
	if _columns_nodes.is_empty(): return
	for column in _columns_nodes:
		column.theme = _columns_hsplit_theme

func _update_cells_line_edit_theme() -> void:
	if _cells_nodes.is_empty(): return
	for cell in _cells_nodes:
		cell.theme = _cell_line_edit_theme
#endregion

#region Private variables
var _data_source:Array[Dictionary]

var data_source:Array[Dictionary]:
	get: return _data_source
	set(value):
		_data_source = value.duplicate(true)
		_sorted_data_source = data_source.duplicate()
		if included_fields.is_empty() and not data_source.is_empty():
			included_fields = data_source[0].keys()
		data_source_changed.emit()
		sort()

var obj_data_source:Array[Object]:
	get:
		var items:Array[Object]
		for item in data_source:
			items.append(dict_to_inst(item))
		return items
	set(value):
		var items:Array[Dictionary]
		for item in value:
			items.append(inst_to_dict(item))
		data_source = items

var _sorted_data_source:Array[Dictionary]
var _sorted_by:int = -1
var _sorted_descending:bool = false
#endregion

#region Public variables
var included_fields:PackedStringArray
var columns_names:PackedStringArray
#endregion

#region Structural Nodes

var _mc := MarginContainer.new()
var _sc := ScrollContainer.new()
var _vbc := VBoxContainer.new()

var _columns_nodes:Array[BetterColumn]
var _cells_nodes:Array[BetterCell]

#endregion

#region _enter_tree()

func _enter_tree() -> void:
	_add_margin_container()
	_add_scroll_container()
	_add_hbox_container()

#endregion

#region Nodes Initializers
func _add_margin_container() -> void:
	_mc.set_anchors_preset(Control.PRESET_FULL_RECT)
	if _mc.get_parent() != self: add_child(_mc)

func _add_scroll_container() -> void:
	_sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _sc.get_parent() != _mc: _mc.add_child(_sc)

func _add_hbox_container() -> void:
	_vbc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if _vbc.get_parent() != _sc: _sc.add_child(_vbc)
#endregion

#region _on_cell_double_clicked()

func _on_cell_double_clicked(cell:BetterCell) -> void:
	row_double_clicked.emit(_cell_to_dict(cell))

#endregion

#region _on_cell_right_clicked()

func _on_cell_right_clicked(cell:BetterCell) -> void:
	row_right_clicked.emit(_cell_to_dict(cell))

#endregion

#region _cell_to_dict()

func _cell_to_dict(cell:BetterCell) -> Dictionary:
	var item_dict:Dictionary
	for field in included_fields:
		item_dict[field] = _data_source[cell.row_idx][field]
	return item_dict

#endregion

#region sort_by_column()

func sort() -> void:
	if _sorted_by < 0 or _sorted_by >= included_fields.size():
		_sorted_data_source = data_source.duplicate()
		build_table()
		return

	var field:String = included_fields[_sorted_by]
	if _sorted_descending:
		_sorted_data_source.sort_custom(func(a,b): return a[field] < b[field])
	else:
		_sorted_data_source.sort_custom(func(a,b): return a[field] > b[field])

	build_table()

func _on_header_pressed(col_idx:int) -> void:
	if _sorted_by == col_idx:
		if _sorted_descending:
			_sorted_by = -1
			_sorted_descending = false
			sort()
			return
		else:
			_sorted_descending = true
			sort()
			return
	else:
		_sorted_descending = false
		_sorted_by = col_idx
		sort()
#endregion

#region _properties_validation()

func _properties_validations() -> bool:
	if _data_source.is_empty():
		_clear_cells()
		return false

	if included_fields.is_empty(): return false

	if not columns_names.is_empty():
		assert(columns_names.size() == included_fields.size(), "columns_names must contain the same amount of items than included_fields")
		if columns_names.size() != included_fields.size(): columns_names = included_fields
	else: columns_names = included_fields
	return true

#endregion

#region _make_column()

func _make_column(column_name:String) -> HSplitContainer:
	var col := BetterColumn.new(_columns_nodes.size())
	col.theme = _columns_hsplit_theme
	var header := Button.new()
	header.theme = _header_button_theme
	header.text = column_name
	col.add_cell(header)
	header.pressed.connect(_on_header_pressed.bind(col.idx))
	return col

#endregion

#region _clear_table()

func _clear_columns() -> void:
	for column in _columns_nodes:
		column.queue_free()
	_columns_nodes.clear()

#endregion

#region _clear_cells()

func _clear_cells() -> void:
	for cell in _cells_nodes:
		cell.queue_free()
	_cells_nodes.clear()

#endregion

#region _add_columns()

func _add_columns() -> void:
	for field_index in included_fields.size():
		var col:HSplitContainer
		if _columns_nodes.is_empty():
			col = _make_column(columns_names[field_index])
			_columns_nodes.append(col)
			_vbc.add_child(col)
			continue

		col = _make_column(columns_names[field_index])
		_columns_nodes.append(col)
		_columns_nodes[field_index -1].add_child(col)

#endregion

#region _fill_table()

func _fill_table() -> void:
	var dict_index := -1
	for dict:Dictionary in _sorted_data_source:
		dict_index += 1
		var field_index := -1
		for field in included_fields:
			field_index += 1
			assert(dict.has(field), "included_field must contain only existing fields.")
			if not dict.has(field): return

			var cell := BetterCell.new(dict_index, field_index, str(dict[field]))
			cell.theme = _cell_line_edit_theme
			_cells_nodes.append(cell)
			_columns_nodes[field_index].add_cell(cell)
			cell.double_clicked.connect(_on_cell_double_clicked)
			cell.right_clicked.connect(_on_cell_right_clicked)

#endregion

#region Build Table
func build_table() -> void:
	if not _properties_validations(): return

	_clear_columns()
	_clear_cells()
	_add_columns()
	_fill_table()
#endregion

@tool
extends PanelContainer
class_name BetterTable

signal row_double_clicked(row_dict:Dictionary)
signal row_right_clicked(row_dict:Dictionary)



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

func _enable_mock_table(state:bool) -> void:
	if state:
		var mock_data:Array[Dictionary]
		for i in range(0, _mock_data_count):
			var dict := {ID=i, DESCRIPTION="MockDescription"+str(i), CATEGORY="MockCategory"+str(i)}
			mock_data.append(dict)
		set_data_source(mock_data)
		included_fields = ["ID", "DESCRIPTION", "CATEGORY"]
		build_table()
		return
	_clear_cells()
	_clear_columns()
	set_data_source([])
	included_fields = []

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

func set_data_source(dict_array:Array[Dictionary]) -> void:
	_data_source = dict_array
func get_data_source() -> Array[Dictionary]:
	return _data_source

var _data_source:Array[Dictionary]:
	set(value):
		_data_source = value
		_sorted_data_source = _data_source.duplicate(true)
var _sorted_data_source:Array[Dictionary]
var included_fields:PackedStringArray
var columns_names:PackedStringArray

var sorted_by:int = -1
var sorted_descending:bool = false

#region Structural Nodes

var _mc := MarginContainer.new()
var _sc := ScrollContainer.new()
var _vbc := VBoxContainer.new()

var _columns_nodes:Array[_do_not_use_BetterColumn]
var _cells_nodes:Array[_do_not_use_BetterCell]

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
	add_child(_mc)

func _add_scroll_container() -> void:
	_sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_sc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_mc.add_child(_sc)

func _add_hbox_container() -> void:
	_vbc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_vbc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_sc.add_child(_vbc)
#endregion

#region _on_cell_double_clicked()

func _on_cell_double_clicked(cell:_do_not_use_BetterCell) -> void:
	row_double_clicked.emit(_cell_to_dict(cell))

#endregion

#region _on_cell_right_clicked()

func _on_cell_right_clicked(cell:_do_not_use_BetterCell) -> void:
	row_right_clicked.emit(_cell_to_dict(cell))

#endregion

#region _cell_to_dict()

func _cell_to_dict(cell:_do_not_use_BetterCell) -> Dictionary:
	var item_dict:Dictionary
	for field in included_fields:
		item_dict[field] = _data_source[cell.row_idx][field]
	return item_dict

#endregion

#region sort_by_column()

func sort_by_column(col_idx:int) -> void:
	var field:String = included_fields[col_idx]
	if sorted_by == col_idx:
		if sorted_descending:
			_sorted_data_source = _data_source.duplicate(true)
			build_table()
			sorted_by = -1
			sorted_descending = false
			return
		sorted_descending = true
		_sorted_data_source.sort_custom(func(a,b): return a[field] > b[field])
		build_table()
		return
	sorted_by = col_idx
	sorted_descending = false
	_sorted_data_source.sort_custom(func(a,b): return a[field] < b[field])
	build_table()

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
	var col := _do_not_use_BetterColumn.new(_columns_nodes.size())
	col.theme = _columns_hsplit_theme
	var header := Button.new()
	header.theme = _header_button_theme
	header.text = column_name
	col.add_cell(header)
	header.pressed.connect(sort_by_column.bind(col.idx))
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

			var cell := _do_not_use_BetterCell.new(dict_index, field_index, str(dict[field]))
			cell.theme = _cell_line_edit_theme
			_cells_nodes.append(cell)
			_columns_nodes[field_index].add_cell(cell)
			cell.double_clicked.connect(_on_cell_double_clicked)
			cell.right_clicked.connect(_on_cell_right_clicked)

#endregion

func remove_row(row_dict:Dictionary) -> void:
	_data_source.erase(row_dict)
	_sorted_data_source.erase(row_dict)
	build_table()

func remove_row_at(row_idx:int) -> void:
	var dict := _sorted_data_source[row_idx]
	_sorted_data_source.remove_at(row_idx)
	_data_source.erase(dict)
	build_table()

func build_table() -> void:
	if not _properties_validations(): return

	_clear_columns()
	_clear_cells()
	_add_columns()
	_fill_table()

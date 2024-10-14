extends HSplitContainer

var idx:int
var _vbc := VBoxContainer.new()

func _init(_idx:int) -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	#dragger_visibility = SplitContainer.DRAGGER_HIDDEN
	add_child(_vbc)
	_vbc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_vbc.size_flags_vertical = Control.SIZE_EXPAND_FILL
	idx = _idx
	if idx == 0:
		split_offset = -400

func add_cell(cell:Node) -> void:
	_vbc.add_child(cell)

func remove_cell(cell:Node) -> void:
	_vbc.remove_child(cell)

func remove_all_cells() -> void:
	for child in _vbc.get_children():
		_vbc.remove_child(child)
		child.queue_free()

@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type(
		"BetterTable",
		"Control",
		preload("res://addons/bettertable/better_table.gd"),
		preload("res://addons/bettertable/BetterTable_icon.png")
	)


func _exit_tree() -> void:
	remove_custom_type("BetterTable")

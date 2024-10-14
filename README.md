# BetterTable

BetterTable is a plugin for easily creating dynamic tables in Godot projects.

## Key Features

- **Flexible Data Source**: Accepts data in the format of an Array of Dictionaries, allowing easy integration with various data structures.
- **Customizable Fields**: Specify which dictionary fields to display in the table using the 'included_fields' property.
- **Custom Column Names**: Define personalized names for table columns using the 'columns_names' property.
- **Column Sorting**: Implements sorting functionality when clicking on column headers.
- **Interactivity**: Provides events for double-click and right-click on table rows.
- **Customizable Themes**: Allows visual customization of various table elements through exported themes.

## Basic Usage Example

You can find this scene in the Demo folder

```gdscript
extends Control

## Demo data
const Dict:Array[Dictionary] = [
	{"ID":0, "NAME":"Bob", "AGE":27, "JOB":"Pharmacist"},
	{"ID":1, "NAME":"David", "AGE":19, "JOB":"Balconist"},
	{"ID":2, "NAME":"John", "AGE":35, "JOB":"Engineer"},
	{"ID":3, "NAME":"Wilson", "AGE":32, "JOB":"Builder"},
	{"ID":4, "NAME":"Kate", "AGE":25, "JOB":"Astronaut"}
]

## Getting the instance from the scene_tree
@onready var better_table:BetterTable = %BetterTable

func _ready() -> void:

	better_table.row_double_clicked.connect(_on_row_double_clicked)
	better_table.row_right_clicked.connect(_on_row_right_clicked)
	## These are the fields that should be displayed
	better_table.included_fields = ["ID", "NAME", "AGE", "JOB"]

	## This is optional, define if you want custom headers names.
	## If you define it though, it must contain, for now, the same amount of fields than included_fields
	better_table.columns_names = ["Identifier", "Name", "Age", "Job"]

	## Give the parameter data_source your desired array of dictionaries,
	## for now, defining this will automatically build the table, so leave this for last.
	better_table.data_source = Dict

func _on_row_right_clicked(row:Dictionary) -> void:
	%Label.text = "Right Clicked: "+str(row)
func _on_row_double_clicked(row:Dictionary) -> void:
	%Label2.text = "Double clicked: "+str(row)
```

This plugin is a proof of concept and it may receive breaking updates.

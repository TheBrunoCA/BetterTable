# BetterTable

BetterTable is a plugin for easily creating dynamic tables in Godot projects.

## Key Features

- **Flexible Data Source**: Accepts data in the format of an Array of Dictionaries, allowing easy integration with various data structures.
- **Customizable Fields**: Specify which dictionary fields to display in the table using the 'included_fields' property.
- **Custom Column Names**: Define personalized names for table columns using the 'columns_names' property.
- **Column Sorting**: Implements sorting functionality when clicking on column headers.
- **Interactivity**: Provides events for double-click and right-click on table rows.
- **Customizable Themes**: Allows visual customization of various table elements through exported themes.
- **Demo Mode**: Includes a simulated table mode for testing and demonstration purposes.

## How to Use

1. **Initial Setup**:
   - Instantiate BetterTable in your scene.
   - Set the data source using the 'set_data_source()' method.
   - Specify fields to be included through the 'included_fields' property.

2. **Customization**:
   - Optionally define custom names for columns using 'columns_names'.
   - Adjust visual themes as needed (panel_container_theme, header_button_theme, etc.).

3. **Table Construction**:
   - Call the 'build_table()' method to render the table with current settings.

4. **Interactivity**:
   - Connect to 'row_double_clicked' and 'row_right_clicked' signals to respond to user interactions.

5. **Sorting**:
   - Sorting is automatic when clicking on column headers.

## Basic Usage Example

```gdscript
var better_table = BetterTable.new()

var data = [
    {ID=1, NAME="John", AGE=30},
    {ID=2, NAME="Alice", AGE=25},
    {ID=3, NAME="Bob", AGE=35}
]

func _ready():
    add_child(better_table)

    better_table.set_data_source(data)
    better_table.included_fields = ["ID", "NAME", "AGE"]
    better_table.build_table()

    better_table.row_double_clicked.connect(_on_row_double_clicked)

func _on_row_double_clicked(row_dict):
    print("Row clicked:", row_dict)
```

This README is temporary and may be updated.

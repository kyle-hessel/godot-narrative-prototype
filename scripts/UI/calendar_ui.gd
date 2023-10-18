extends CanvasLayer

class_name CalendarUI

var calendar_year_num: int = GameManager.calendar_manager.current_year_num
var calendar_month_num: int = GameManager.calendar_manager.current_month_num
@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle
var date_entry: PackedScene = preload("res://scenes/UI/date_ui.tscn")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)
	
	generate_date_grid()

func generate_date_grid() -> void:
	var current_day: int = GameManager.calendar_manager.current_day_num
	
	for d in range(GameManager.calendar_manager.month.days.size()):
		var date_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_inst)
		
		date_inst.date_number.text = str(d + 1)
		date_inst.calendar_day_num = d
		if d == current_day:
			date_inst.date_panel.modulate = "d6b247"

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

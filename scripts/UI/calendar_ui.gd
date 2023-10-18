extends CanvasLayer

class_name CalendarUI

var calendar_year_num: int = GameManager.calendar_manager.current_year_num
var calendar_month_num: int = GameManager.calendar_manager.current_month_num
@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle
@onready var arrow_left: CalendarArrowUI = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/CalendarArrowUILeft
@onready var arrow_right: CalendarArrowUI = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/CalendarArrowUIRight

var date_entry: PackedScene = preload("res://scenes/UI/date_ui.tscn")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)
	arrow_left.dir_right = false # only set the left arrow, right defaults to true
	arrow_left.on_click.connect(_month_left)
	arrow_right.on_click.connect(_month_right)
	
	generate_date_grid()

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func generate_date_grid() -> void:
	var current_day: int = GameManager.calendar_manager.current_day_num
	
	for d in range(GameManager.calendar_manager.month.days.size()):
		var date_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_inst)
		
		date_inst.date_number.text = str(d + 1)
		date_inst.calendar_day_num = d
		if d == current_day:
			date_inst.date_panel.modulate = "d6b247"

func _month_left() -> void:
	print("back in time!")

func _month_right() -> void:
	print("forward in time!")

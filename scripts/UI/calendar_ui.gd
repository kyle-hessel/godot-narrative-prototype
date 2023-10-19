extends CanvasLayer

class_name CalendarUI

var calendar_year_num: int
var calendar_month_num: int
@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle
@onready var arrow_left: CalendarArrowUI = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/CalendarArrowUILeft
@onready var arrow_right: CalendarArrowUI = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/CalendarArrowUIRight

var date_entry: PackedScene = preload("res://scenes/UI/date_ui.tscn")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	calendar_year_num = GameManager.calendar_manager.current_year_num
	calendar_month_num = GameManager.calendar_manager.current_month_num
	
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)
	arrow_left.on_click.connect(_month_left)
	arrow_right.on_click.connect(_month_right)
	
	generate_date_grid(GameManager.calendar_manager.month)

func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func generate_date_grid(month: Month) -> void:
	var current_day: int = GameManager.calendar_manager.current_day_num
	
	for d in range(month.days.size()):
		var date_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_inst)
		
		date_inst.date_number.text = str(d + 1)
		date_inst.calendar_day_num = d
		if d == current_day:
			date_inst.date_panel.modulate = "d6b247"

# shift back a month
func _month_left() -> void:
	# this if check avoids going backwards past the start of the academic calendar.
	if calendar_month_num > 7 || calendar_year_num > 0:
		print("back in time!")
		calendar_month_num -= 1
		
		for c in %DaysGrid.get_children():
			c.queue_free()
		
		rebuild_calendar()

# shift forward a month
func _month_right() -> void:
	# NOTE: add an if check later like above to stop from going past the end of the 4-year academic calendar.
	print("forward in time!")
	calendar_month_num += 1
	
	for c in %DaysGrid.get_children():
		c.queue_free()
	
	rebuild_calendar()

func rebuild_calendar() -> void:
	var year_fetch: Year = load(GameManager.calendar_manager.game_calendar.years[calendar_year_num].resource_path)
	var month_fetch: Month = load(year_fetch.months[calendar_month_num].resource_path)
	
	month_title.text = month_fetch.title
	generate_date_grid(month_fetch)

extends CanvasLayer

class_name CalendarUI

var calendar_year_num: int
var calendar_month_num: int
var using_joypad: bool
@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle
@onready var arrow_left: CalendarArrowUI = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/CalendarArrowUILeft
@onready var arrow_right: CalendarArrowUI = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/CalendarArrowUIRight

var date_entry: PackedScene = preload("res://scenes/UI/date_ui.tscn")

signal show_mouse
signal hide_mouse

func _ready():
	emit_signal("show_mouse")
	
	calendar_year_num = GameManager.calendar_manager.current_year_num
	calendar_month_num = GameManager.calendar_manager.current_month_num
	
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)
	arrow_left.on_click.connect(_month_left)
	arrow_right.on_click.connect(_month_right)
	
	generate_date_grid(GameManager.calendar_manager.month, GameManager.calendar_manager.year)

func _exit_tree():
	emit_signal("hide_mouse")

# generates all days of the current month.
func generate_date_grid(month: Month, year: Year) -> void:
	var current_day: int = GameManager.calendar_manager.current_day_num
	var month_start_weekday: Day.WeekDay = month.days[0].week_day
	
	# populate DaysGrid with any days from the last month that show up in the first week row.
	if month_start_weekday != Day.WeekDay.SUNDAY:
		# if month is not january, use the current year to load days from previous month.
		if calendar_month_num > 0:
			var month_fetch: Month = load(year.months[calendar_month_num - 1].resource_path)
			generate_date_grid_previous_month(month_fetch.days.size(), month_start_weekday)
		# if month is january, use the prior year to load days from the previous month.
		else:
			var year_fetch: Year = load(GameManager.calendar_manager.game_calendar.years[calendar_year_num - 1].resource_path)
			var month_fetch: Month = load(year_fetch.months[11].resource_path)
			generate_date_grid_previous_month(month_fetch.days.size(), month_start_weekday)
	
	# populate DaysGrid with all of the days of the current month.
	for d in range(month.days.size()):
		var date_ui_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_ui_inst)
		
		date_ui_inst.in_current_month = true
		date_ui_inst.date_number.text = str(d + 1)
		date_ui_inst.calendar_day_num = d
		date_ui_inst.calendar_year = year
		date_ui_inst.calendar_month = month
		if month == GameManager.calendar_manager.month:
			if d == current_day:
				date_ui_inst.date_panel.modulate = "d6b247"
		
		date_ui_inst.init_events()
	
	# populate DaysGrid with any days from the next month that show up in the last week row.
	var remaining_days_to_fill: int = 42 - %DaysGrid.get_children().size()
	
	generate_date_grid_next_month(remaining_days_to_fill)

# generates any days from the prior month that need to show up on the grid of the current month
func generate_date_grid_previous_month(previous_month_size: int, start_day: int) -> void:
	var month_day_pos: int = previous_month_size - start_day
	
	for d in range(start_day):
		var date_ui_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_ui_inst)
		
		date_ui_inst.in_current_month = false
		date_ui_inst.date_number.text = str(month_day_pos + 1)
		date_ui_inst.calendar_day_num = month_day_pos
		month_day_pos += 1
		date_ui_inst.date_panel.modulate = "586ebcbe"

# generates any days from the next month that need to show up on the grid of the current month
func generate_date_grid_next_month(day_count: int) -> void:
	for d in range(day_count):
		var date_ui_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_ui_inst)
		
		date_ui_inst.in_current_month = false
		date_ui_inst.date_number.text = str(d + 1)
		date_ui_inst.calendar_day_num = d
		date_ui_inst.date_panel.modulate = "586ebcbe"

# shift back a month
func _month_left() -> void:
	# this if check avoids going backwards past the start of the academic calendar (august 2024).
	if calendar_month_num > 7 || calendar_year_num > 0:
		print("back in time!")
		
		# if in january, roll over to the year before (if we got this far, meaning we are in >=2025).
		if calendar_month_num == 0:
			calendar_year_num -= 1
			calendar_month_num = 11
		# otherwise, just decrement month.
		else:
			calendar_month_num -= 1
		
		for c in %DaysGrid.get_children():
			%DaysGrid.remove_child(c)
			c.queue_free()
		
		rebuild_calendar()

# shift forward a month
func _month_right() -> void:
	# this if check avoids going forwards past the end of the academic calendar (may 2028).
	if calendar_month_num < 5 || calendar_year_num < 4:
		print("forward in time!")
		
		# if in december, roll over into the next year.
		if calendar_month_num == 11:
			calendar_year_num += 1
			calendar_month_num = 0
		# otherwise, just increment month.
		else:
			calendar_month_num += 1
		
		for c in %DaysGrid.get_children():
			%DaysGrid.remove_child(c)
			c.queue_free()
		
		rebuild_calendar()

func rebuild_calendar() -> void:
	var year_fetch: Year = load(GameManager.calendar_manager.game_calendar.years[calendar_year_num].resource_path)
	var month_fetch: Month = load(year_fetch.months[calendar_month_num].resource_path)
	
	year_title.text = str(year_fetch.number)
	month_title.text = month_fetch.title
	generate_date_grid(month_fetch, year_fetch)

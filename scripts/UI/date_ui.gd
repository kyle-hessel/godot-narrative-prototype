extends Control

class_name DateUI

@onready var date_panel: PanelContainer = $DatePanel
@onready var date_number: Label = $DatePanel/DatePanelMargin/DateNumber



var calendar_day_num: int

var is_mouse_entered: bool = false

func _ready():
	pass

func _process(delta: float) -> void:
	pass

func _on_date_panel_mouse_entered():
	is_mouse_entered = true

func _on_date_panel_mouse_exited():
	is_mouse_entered = false

func _on_date_panel_gui_input(event: InputEvent):
	if is_mouse_entered && event.is_action_pressed("gui_select"):
		# fetch year and month here instead of at the initialization of EVERY date_ui instance. The information will
		# almost never be needed for *all* of them, so it will be more efficient to just fetch this on the fly as requested.
		var calendar_year_num: int = UIManager.calendar_ui_inst.calendar_year_num
		var calendar_month_num: int = UIManager.calendar_ui_inst.calendar_month_num
		
		# if the UI's month and year matches the current month and year, just use that data, as it is faster than loading again from a resource.
		# it makes sense to check for this first, as it is the most likely outcome (players will check the calendar for the given month they are in most often).
		if UIManager.calendar_ui_inst.calendar_year_num == GameManager.calendar_manager.current_year_num && UIManager.calendar_ui_inst.calendar_month_num == GameManager.calendar_manager.current_month_num:
			var year_fetch: Year = GameManager.calendar_manager.year
			var month_fetch: Month = GameManager.calendar_manager.month
			
			var day_fetch: Day = month_fetch.days[calendar_day_num]
			
			print(month_fetch.title + " " + str(calendar_day_num + 1) + ", " + str(year_fetch.number))
			GameManager.calendar_manager.print_date_events(day_fetch)
			
		# if the UI's month/year do NOT match the current month and year, that means the player is moving around the calendar.
		# in this case, we have to dynamically load this data in again briefly.
		else:
			var year_fetch: Year = load(GameManager.calendar_manager.game_calendar.years[calendar_year_num].resource_path)
			var month_fetch: Month = load(year_fetch.months[calendar_month_num].resource_path)
			
			# keep in mind the resources have already been loaded, now we're just fetching them from the variable that stored said load().
			var day_fetch: Day = month_fetch.days[calendar_day_num]
			
			print(month_fetch.title + " " + str(calendar_day_num + 1) + ", " + str(year_fetch.number))
			GameManager.calendar_manager.print_date_events(day_fetch)

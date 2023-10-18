extends Control

class_name DateUI

@onready var date_panel: PanelContainer = $DatePanel
@onready var date_number: Label = $DatePanel/DatePanelMargin/DateNumber

var calendar_day_num: int

var is_mouse_entered: bool = false

func _ready():
	pass

func _process(delta: float) -> void:
	if is_mouse_entered && Input.is_action_just_pressed("gui_select"):
		# fetch year and month here instead of at the initialization of EVERY date_ui instance. The information will
		# almost never be needed for *all* of them, so it will be more efficient to just fetch this on the fly as requested.
		var year_fetch: Year = GameManager.calendar_manager.year
		var month_fetch: Month = GameManager.calendar_manager.month
		
		# keep in mind the resources have already been loaded, now we're just fetching them from the variable that stored said load().
		var day_fetch: Day = month_fetch.days[calendar_day_num]
		
		print(year_fetch.number)
		print(month_fetch.title)
		print(calendar_day_num + 1)
		GameManager.calendar_manager.print_date_events(day_fetch)
		

func _on_date_panel_mouse_entered():
	is_mouse_entered = true

func _on_date_panel_mouse_exited():
	is_mouse_entered = false

extends CanvasLayer

@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle
var date_entry: PackedScene = preload("res://scenes/UI/date_ui.tscn")

func _ready():
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)
	
	for d in range(GameManager.calendar_manager.month.days.size()):
		var current_day: int = GameManager.calendar_manager.current_day_num
		var date_inst: Control = date_entry.instantiate()
		%DaysGrid.add_child(date_inst)
		
		date_inst.date_number.text = str(d + 1)
		if d == current_day:
			date_inst.date_panel.modulate = "d6b247"

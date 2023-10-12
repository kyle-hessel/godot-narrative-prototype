extends CanvasLayer

@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle
var date_entry: PackedScene = preload("res://scenes/UI/date_ui.tscn")

func _ready():
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)
	
	for d in range(GameManager.calendar_manager.month.days.size()):
		%DaysGrid.add_child(date_entry.instantiate())

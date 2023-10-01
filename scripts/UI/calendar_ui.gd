extends CanvasLayer

@onready var month_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/MonthTitle
@onready var year_title: Label = $CalendarOutsideMargin/CalendarContainer/CalendarInsideMargin/CalendarVBox/TitleHBox/YearTitle

func _ready():
	month_title.text = GameManager.calendar_manager.month.title
	year_title.text = str(GameManager.calendar_manager.year.number)

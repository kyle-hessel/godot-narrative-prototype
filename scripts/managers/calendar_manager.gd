extends Node

class_name CalendarManager

var game_calendar: Calendar = preload("res://scripts/resources/calendars/college_calendar.tres")
var school_year: Year = Year.new()
var month: Month = Month.new()
var day: Day = Day.new()
# these three values will need to be saved
var current_year_num: int = 0
var current_month_num: int = 0
var current_day_num: int = 27

func _ready():
	var todays_events: Dictionary = load_current_date_events()
	print("Today is " + day.week_day + " " + month.title + " " + str(current_day_num) + ", " + str(school_year.calendar_years.get("current_year")) + ".")
	print(todays_events.keys()[0] + " with " + todays_events.get("Hangout") + " today.")

func load_current_date_events() -> Dictionary:
	load_current_date()
	return day.events

func load_current_date() -> void:
	#print(ResourceLoader.exists("res://scripts/resources/calendars/college_calendar.tres"))
	school_year = load(game_calendar.years[current_year_num].resource_path)
	#print(school_year.calendar_years.get("end_year"))
	month = load(school_year.months[current_month_num].resource_path)
	day = load(month.days[current_day_num].resource_path)

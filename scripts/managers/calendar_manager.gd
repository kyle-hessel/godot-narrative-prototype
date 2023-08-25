extends Node

class_name CalendarManager

var game_calendar: Calendar = Calendar.new()
var school_year: Year = Year.new()
var month : Month = Month.new()
var day : Day = Day.new()

func _ready():
	print(ResourceLoader.exists("res://scripts/resources/calendars/college_calendar.tres"))
	game_calendar = ResourceLoader.load("res://scripts/resources/calendars/college_calendar.tres")
	school_year = ResourceLoader.load(game_calendar.years[0].resource_path)
	print(school_year.calendar_years.get("end_year"))
	month = ResourceLoader.load(school_year.months[0].resource_path)
	day = ResourceLoader.load(month.days[0].resource_path)
	print(day.events.keys()[0] + " with " + day.events.get("Hangout") + " today.")

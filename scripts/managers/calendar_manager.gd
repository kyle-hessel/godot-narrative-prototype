extends Node

class_name CalendarManager

var game_calendar: Calendar = preload("res://scripts/resources/calendars/college_calendar.tres")
var school_year: Year = Year.new()
var month: Month = Month.new()
var day: Day = Day.new()
# these three values will need to be saved
var current_year_num: int = 0
var current_month_num: int = 0
var current_day_num: int = 24

func _ready() -> void:
	# first-time date load on game startup.
	load_current_date()
	
	print_date()
	var todays_events: Dictionary = day.events
	print(todays_events.keys()[0] + " with " + todays_events.get(todays_events.keys()[0]) + " today.")
	
func process() -> void:
	pass
	
func print_date() -> void:
	print("Today is " + day.week_day + " " + month.title + " " + str(current_day_num + 1) + ", " + str(school_year.calendar_years.get("current_year")) + ".")

func print_date_events() -> void:
	pass

# load current date data into memory using saved array positions.
func load_current_date() -> void:
	#print(ResourceLoader.exists("res://scripts/resources/calendars/college_calendar.tres"))
	school_year = load(game_calendar.years[current_year_num].resource_path)
	#print(school_year.calendar_years.get("end_year"))
	month = load(school_year.months[current_month_num].resource_path)
	day = load(month.days[current_day_num].resource_path)

# only use this for counts less than ~28, (the min size of a month) which is all that should be needed anyhow.
func advance_date(count: int = 1) -> void:
	# add a check here later to not advance past the last calendar day, whatever that ends up being.
	
	# if advancing by the current count jumps to a new month, determine what to do.
	if (current_day_num + count) >= month.days.size() - 1:
		# if in the last month of the year, advance both year and month.
		if month.title == "December":
			current_year_num += 1
			current_month_num = 0
		# otherwise just advance the month.
		else:
			current_month_num += 1
		# subtract any days from the previous month that were skipped by count before setting current_day_num using count
		var last_month_difference: int = (month.days.size() - 1) - current_day_num
		current_day_num = (count - last_month_difference) - 1  # subtract one since day array starts at 0, not 1.
	# if the count stays in the same month, just increment day count.
	else:
		current_day_num += count
	# load the new date.
	load_current_date()

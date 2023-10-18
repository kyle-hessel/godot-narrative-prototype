extends Node

class_name CalendarManager

var game_calendar: Calendar = preload("res://scripts/resources/calendars/college_calendar.tres")
var year: Year = Year.new()
var month: Month = Month.new()
var day: Day = Day.new()
# these three values will need to be saved. They're all the current display day/month/year, minus one.
# game start date on new save: (7-24-0 - which is Sunday August 25, 2024).
var current_year_num: int = 0
var current_month_num: int = 7
var current_day_num: int = 24

func _ready() -> void:
	# first time current date load on game startup. loads everything (day/month/year) by default.
	load_current_date()
	print_date_info()
	

func _process(delta) -> void:
	if Input.is_action_just_pressed("day_increment_test"):
		print("Starting next day.")
		advance_date()
		print_date_info()

func print_date_info() -> void:
	print_date()
	print_date_weather()
	print_date_events(day)
	
func print_date() -> void:
	var week_day: String
	
	match day.week_day:
		day.WeekDay.SUNDAY:
			week_day = "Sunday"
		day.WeekDay.MONDAY:
			week_day = "Monday"
		day.WeekDay.TUESDAY:
			week_day = "Tuesday"
		day.WeekDay.WEDNESDAY:
			week_day = "Wednesday"
		day.WeekDay.THURSDAY:
			week_day = "Thursday"
		day.WeekDay.FRIDAY:
			week_day = "Friday"
		day.WeekDay.SATURDAY:
			week_day = "Saturday"
	
	print("Today is " + week_day + " " + month.title + " " + str(current_day_num + 1) + ", " + str(year.number) + ".")

func print_date_weather() -> void:
	var forecast: String
	match day.weather:
		day.Weather.SUNNY:
			forecast = "sun"
		day.Weather.CLOUDY:
			forecast = "clouds"
		day.Weather.RAINY:
			forecast = "rain"
		day.Weather.LIGHTNING:
			forecast = "rain with lightning"
		day.Weather.SNOW:
			forecast = "snow"
		day.Weather.SUNNY_WIND:
			forecast = "snow with wind"
		day.Weather.CLOUDY_WIND:
			forecast = "clouds with wind"
		day.Weather.RAINY_WIND:
			forecast = "rain with wind"
		day.Weather.LIGHTNING_WIND:
			forecast = "rain with wind and lightning"
		day.Weather.SNOW_WIND:
			forecast = "a blizzard"
		day.Weather.FOGGY:
			forecast = "fog"
		_:
			forecast = "sun"
	
	print("The forecast today shows " + forecast + ".")

func print_date_events(day: Day) -> void:
	if day.holiday != "none":
		print("Today is a holiday: " + day.holiday + ".")
	
	print("Today's events:")
	
	for event in day.events.keys():
		match event:
			"Hangout":
				print(event + " with " + day.events.get(event) + ".")
			"Attend":
				print(event + " " + day.events.get(event) + ".")
			"Work":
				print(event + " at " + day.events.get(event) + ".")
			"Visit":
				print(event + " " + day.events.get(event) + ".")
			"Move":
				print(event + " to " + day.events.get(event) + ".")
			_:
				print("event: " + event + ", " + day.events.get(event) + ".")

# load current date data into memory using saved array positions. 
# false inputs lead to not reloading existing months/years when unnecessary.
# inputs are true by default for cleaner _ready call, as loading everything is necessary on game boot.
func load_current_date(load_month: bool = true, load_year: bool = true) -> void:
	#print(ResourceLoader.exists("res://scripts/resources/calendars/college_calendar.tres"))
	if load_year:
		year = load(game_calendar.years[current_year_num].resource_path)
		#print("year loaded.")
	if load_month:
		month = load(year.months[current_month_num].resource_path)
		#print("month loaded.")
		
	# always load days regardless of inputs.
	day = load(month.days[current_day_num].resource_path)
	#print("day loaded.")

# only use this for counts less than ~28, (the min size of a month) which is all that should be needed anyhow.
func advance_date(count: int = 1) -> void:
	# decide if new months or years need to be loaded; false by default as most days will stay in the same month/year.
	var is_new_month: bool = false
	var is_new_year: bool = false
	
	# if advancing by the current count jumps to a new month, determine what to do.
	if (current_day_num + count) >= month.days.size():
		
		# if in the last month of the year, advance both year and month.
		if month.title == "December":
			current_year_num += 1
			current_month_num = 0
			is_new_year = true
			is_new_month = true
		
		# otherwise just advance the month.
		else:
			current_month_num += 1
			is_new_month = true
		# subtract any days from the previous month that were skipped by count before setting current_day_num using count
		var last_month_difference: int = (month.days.size() - 1) - current_day_num
		current_day_num = (count - last_month_difference) - 1  # subtract one since day array starts at 0, not 1.
		
	# if the count stays in the same month, just increment day count.
	else:
		current_day_num += count
	
	# load the new date.
	load_current_date(is_new_month, is_new_year)

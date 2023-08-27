extends Node

class_name CalendarManager

var game_calendar: Calendar = preload("res://scripts/resources/calendars/college_calendar.tres")
var year: Year = Year.new()
var month: Month = Month.new()
var day: Day = Day.new()
# these three values will need to be saved
var current_year_num: int = 0
var current_month_num: int = 7
var current_day_num: int = 24

func _ready() -> void:
	# first-time date load on game startup.
	load_current_date()
	print_date_info()
	
func _process(delta) -> void:
	if Input.is_action_just_pressed("day_increment_test"):
		print("Starting next day.")
		advance_date(1)
		print_date_info()

func print_date_info() -> void:
	print_date()
	print_date_weather()
	print_date_events()
	
func print_date() -> void:
	print("Today is " + day.week_day + " " + month.title + " " + str(current_day_num + 1) + ", " + str(year.number) + ".")

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

func print_date_events() -> void:
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
func load_current_date() -> void:
	#print(ResourceLoader.exists("res://scripts/resources/calendars/college_calendar.tres"))
	year = load(game_calendar.years[current_year_num].resource_path)
	#print(school_year.calendar_years.get("end_year"))
	month = load(year.months[current_month_num].resource_path)
	day = load(month.days[current_day_num].resource_path)

# only use this for counts less than ~28, (the min size of a month) which is all that should be needed anyhow.
func advance_date(count: int = 1) -> void:
	# add a check here later to not advance past the last calendar day, whatever that ends up being.
	
	# if advancing by the current count jumps to a new month, determine what to do.
	if (current_day_num + count) >= month.days.size():
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

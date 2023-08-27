extends Resource

class_name Day

enum WeekDay {
	SUNDAY = 0,
	MONDAY = 1,
	TUESDAY = 2,
	WEDNESDAY = 3,
	THURSDAY = 4,
	FRIDAY = 5,
	SATURDAY = 6
}

@export var week_day: WeekDay = WeekDay.SUNDAY
@export var holiday: String = "none"

enum Weather {
	SUNNY = 0,
	CLOUDY = 1,
	RAINY = 2,
	LIGHTNING = 3,
	SNOW = 4,
	SUNNY_WIND = 5,
	CLOUDY_WIND = 6,
	RAINY_WIND = 7,
	LIGHTNING_WIND = 8,
	SNOW_WIND = 9,
	FOGGY = 10
}

@export var weather: Weather = Weather.SUNNY
@export var wind_multiplier: float = 0.0
@export var events: Dictionary = {}

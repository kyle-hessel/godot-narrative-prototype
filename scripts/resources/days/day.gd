extends Resource

class_name Day

@export var week_day: String = "Sunday"
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

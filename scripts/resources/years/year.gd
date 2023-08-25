extends Resource

class_name Year

@export var title: String = "Year"
@export var calendar_years = {
	"start_year" : 2024,
	"end_year" : 2025
}
@export var start_month: int = 8
@export var start_day: int = 26
@export var months: Array[Month] = []

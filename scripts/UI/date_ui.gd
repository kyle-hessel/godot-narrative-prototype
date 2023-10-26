extends Control

class_name DateUI

@onready var date_panel: PanelContainer = $DatePanel
@onready var date_number: Label = $DateNumber
@onready var events_grid: GridContainer = $DatePanel/DatePanelMargin/EventsGrid

var event_indicator: PackedScene = preload("res://scenes/UI/date_ui_event_indicator.tscn")

var calendar_day_num: int
var calendar_year: Year
var calendar_month: Month
var calendar_day: Day
var in_current_month: bool

func _ready():
	pass

func _process(delta: float) -> void:
	pass

func init_events() -> void:
	calendar_day = calendar_month.days[calendar_day_num]

	for e in calendar_day.events.keys():
		var event_indicator_inst: Control = event_indicator.instantiate()
		events_grid.add_child(event_indicator_inst)
		
		match e:
			"Hangout":
				event_indicator_inst.indicator_mesh.modulate = "b8526e"
			"Attend":
				event_indicator_inst.indicator_mesh.modulate = "5472cf"
			"Work":
				event_indicator_inst.indicator_mesh.modulate = "bf542f"
			"Visit":
				event_indicator_inst.indicator_mesh.modulate = "3c8b67"
			"Move":
				event_indicator_inst.indicator_mesh.modulate = "b0a256"

func _on_date_panel_gui_input(event: InputEvent):
	if event.is_action_pressed("gui_select") && in_current_month:
		print(calendar_month.title + " " + str(calendar_day_num + 1) + ", " + str(calendar_year.number))
		GameManager.calendar_manager.print_date_events(calendar_day)

extends Node

onready var start_position = get_parent().global_position
onready var target_position = get_parent().global_position
onready var timer = $Timer

export(int) var wander_range = 32

func update_target_position():
	var target_vector = Vector2(rand_range(-wander_range,wander_range), rand_range(-wander_range,wander_range))
	target_position = start_position + target_vector

func set_wander_timer(duration):
	timer.start(duration)

func return_time_left():
	return timer.time_left

func _on_Timer_timeout() -> void:
	update_target_position()

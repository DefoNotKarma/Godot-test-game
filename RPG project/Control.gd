extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		var pause = not get_tree().paused
		get_tree().paused = pause
		visible = pause
		

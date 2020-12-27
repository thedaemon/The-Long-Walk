extends Spatial

# An input function, Debug Tools for the level
func _input(_event):
	# Rotates the lighting of the map including the Fog Sky and Sun
	if Input.is_action_pressed("random"):
		$Environment.rotate_y(0.075)
	# Changes the environment map
	if Input.is_action_pressed("lighting"):
		$Environment/AnimationPlayer.playback_speed = 2
		yield(get_tree().create_timer(0.5), "timeout")
		$Environment/AnimationPlayer.playback_speed = 0.01
		

class_name WallJumpPlayerState extends PlayerMovementState

func enter(previous_state) -> void:
	# Immediately transition to Falling state after the horizontal jump impulse is applied.
	transition.emit("FallingPlayerState")

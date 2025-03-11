class_name FallingPlayerState extends PlayerMovementState

@export var SPEED : float = 5.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

var peak_fall_velocity: float = 0.0  

func enter(previous_state) -> void:
	ANIMATION.pause()
	peak_fall_velocity = 0.0  
func update(delta: float) -> void:
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()

	if PLAYER.velocity.y < peak_fall_velocity:
		peak_fall_velocity = PLAYER.velocity.y  

	# Detect landing
	if PLAYER.is_on_floor():
		if peak_fall_velocity <= -10.0:  # Hard landing
			ANIMATION.play("HardFall")
		elif peak_fall_velocity >= -5.0:  # Soft landing
			ANIMATION.play("SoftFall")
			
		transition.emit("IdlePlayerState")

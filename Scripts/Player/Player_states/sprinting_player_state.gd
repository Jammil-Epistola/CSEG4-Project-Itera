class_name SprintingPlayerState extends PlayerMovementState
	
@export var SPEED : float = 10.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("sprint"):
		transition.emit("WalkingPlayerState")
		
	if Input.is_action_just_released("sprint") and PLAYER.velocity.length() == 0:
		transition.emit("IdlePlayerState")
	
	if Input.is_action_just_pressed("crouch") and PLAYER.velocity.length() > 6:
		transition.emit("SlidingPlayerState")
	

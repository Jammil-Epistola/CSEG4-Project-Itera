class_name IdlePlayerState extends PlayerMovementState

var SPEED : float = 0.0
var ACCELERATION : float = 0.1
var DECELERATION : float = 0.25

func enter(previous_state) -> void:
	if ANIMATION.is_playing() and (ANIMATION.current_animation == "SoftFall" or ANIMATION.current_animation == "HardFall"):
		await ANIMATION.animation_finished 

	ANIMATION.pause()
	
func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("crouch") and PLAYER.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir != Vector2.ZERO:  
		transition.emit("WalkingPlayerState")  
	
	if PLAYER.velocity.y < -3.0 and !PLAYER.is_on_floor():
		transition.emit("FallingPlayerState")
	
	if Input.is_action_just_pressed("jump") and PLAYER.is_on_floor():
		transition.emit("JumpingPlayerState")
		

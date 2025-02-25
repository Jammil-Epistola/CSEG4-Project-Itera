class_name IdlePlayerState extends PlayerMovementState

var SPEED : float = 0.0
var ACCELERATION : float = 0.1
var DECELERATION : float = 0.25

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, PLAYER.ACCELERATION, PLAYER.DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_pressed("crouch") and Global.player.is_on_floor():
		transition.emit("CrouchingPlayerState")
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input_dir != Vector2.ZERO:  
		transition.emit("WalkingPlayerState")  

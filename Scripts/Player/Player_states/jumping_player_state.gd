class_name JumpingPlayerState extends PlayerMovementState

@export var SPEED : float = 9.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export var JUMP_VELOCITY : float = 7.2 
@export_range(0.5,1.0,0.01) var INPUT_MULTIPLIER : float = 0.85

func enter(previous_state) -> void:
	PLAYER.velocity.y += JUMP_VELOCITY
	ANIMATION.pause()

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED * INPUT_MULTIPLIER,ACCELERATION,DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("jump"):
		if PLAYER.velocity.y > 0:
			PLAYER.velocity.y = PLAYER.velocity.y /2.0
	if PLAYER.is_on_floor():
		transition.emit("IdlePlayerState")
	
	if PLAYER.velocity.y < 0: 
		transition.emit("FallingPlayerState")

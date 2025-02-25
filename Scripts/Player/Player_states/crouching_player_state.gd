class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED : float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D

func enter() -> void:
	print("Entering Crouch State")  
	print("PLAYER:", PLAYER)  
	print("PLAYER ANIMATION:", PLAYER.ANIMATIONPLAYER)  

	if PLAYER.ANIMATIONPLAYER:
		PLAYER.ANIMATIONPLAYER.play("Crouch", -1.0, CROUCH_SPEED)
	else:
		print("ERROR: ANIMATIONPLAYER is NULL in CrouchingPlayerState!")

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, PLAYER.ACCELERATION, PLAYER.DECELERATION)
	PLAYER.update_velocity()
	
	if Input.is_action_just_released("crouch"):
		uncrouch()

func uncrouch():
	if !CROUCH_SHAPECAST.is_colliding():
		print("Uncrouching!")
		if PLAYER.ANIMATIONPLAYER:
			PLAYER.ANIMATIONPLAYER.play("Crouch", -1.0, -CROUCH_SPEED * 1.5, true)
			await PLAYER.ANIMATIONPLAYER.animation_finished  
			transition.emit("IdlePlayerState")
		else:
			print("ERROR: ANIMATIONPLAYER is NULL during uncrouch!")
	else:
		print("Cannot uncrouch, something is above!")
		await get_tree().create_timer(0.1).timeout
		uncrouch()

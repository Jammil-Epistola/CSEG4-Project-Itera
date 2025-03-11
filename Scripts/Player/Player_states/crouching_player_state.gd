class_name CrouchingPlayerState extends PlayerMovementState

@export var SPEED : float = 3.0
@export var ACCELERATION : float = 0.1
@export var DECELERATION : float = 0.25
@export_range(1, 6, 0.1) var CROUCH_SPEED : float = 4.0

@onready var CROUCH_SHAPECAST: ShapeCast3D = %ShapeCast3D

var RELEASED : bool = false

func enter(previous_state) -> void:
	print("Entering Crouch State")   
	if previous_state.name != "SlidingPlayerState":
		ANIMATION.play("Crouch", -1.0, CROUCH_SPEED)
	elif previous_state.name == "SlidingPlayerState":
		ANIMATION.current_animation = "Crouch"
		ANIMATION.seek(1.0, true)
	else:
		print("ERROR: ANIMATIONPLAYER is NULL in CrouchingPlayerState!")

func exit() -> void:
	RELEASED = false

func update(delta):
	PLAYER.update_gravity(delta)
	PLAYER.update_input(SPEED, ACCELERATION, DECELERATION)
	PLAYER.update_velocity()
	
	# Only uncrouch if the key is released and it was previously held
	if !Input.is_action_pressed("crouch") and RELEASED == false:
		RELEASED = true
		uncrouch()

	if Input.is_action_pressed("crouch"):
		RELEASED = false  # Reset RELEASED if crouch is still held

func uncrouch():
	if !CROUCH_SHAPECAST.is_colliding():
		print("Uncrouching!")
		if PLAYER.ANIMATIONPLAYER:
			PLAYER.ANIMATIONPLAYER.play("Crouch", -1.0, -CROUCH_SPEED * 1.5, true)
			await PLAYER.ANIMATIONPLAYER.animation_finished  
			if PLAYER.velocity.length() == 0:
				transition.emit("IdlePlayerState")
			else:
				transition.emit("WalkingPlayerState")
		else:
			print("ERROR: ANIMATIONPLAYER is NULL during uncrouch!")
	else:
		print("Cannot uncrouch, something is above!")
		await get_tree().create_timer(0.1).timeout
		uncrouch()

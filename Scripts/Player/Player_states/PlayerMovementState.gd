class_name PlayerMovementState extends State

var PLAYER: Player
var ANIMATION : AnimationPlayer

func _ready() -> void:
	await owner.ready
	PLAYER = owner as Player
	
	if PLAYER:
		ANIMATION = PLAYER.ANIMATIONPLAYER 
	else:
		print("ERROR: PLAYER is NULL in PlayerMovementState!")

	# Additional check:
	if ANIMATION == null:
		print("ERROR: ANIMATIONPLAYER is NULL in PlayerMovementState!")

func update(delta):
	if PLAYER:  # Ensure PLAYER is valid before calling functions
		PLAYER.update_gravity(delta)  
		PLAYER.update_input(0.0, PLAYER.ACCELERATION, PLAYER.DECELERATION)
		PLAYER.update_velocity()
	else:
		print("ERROR: PLAYER is NULL during update in", self)

func _process(delta: float) -> void:
	pass

class_name WallRunPlayerState extends PlayerMovementState

@onready var left_wall_check = $"../../WallCheck/LeftWallCheck"
@onready var right_wall_check = $"../../WallCheck/RightWallCheck"
@onready var camera = $"../../Head/Camera3D"

var is_wall_running = false
var is_touching_left_wall = false
var is_touching_right_wall = false
var wall_normal := Vector3.ZERO
var wall_run_direction := Vector3.ZERO

const WALL_RUN_SPEED := 10.0
const WALL_JUMP_FORCE := 12.0
const WALL_JUMP_VERTICAL_BOOST := 10.0
const GRAVITY_REDUCTION := 0.3
const MIN_SPEED_REQUIRED := 9.0
const WALL_PUSH_FORCE := 5.0
const MAX_TILT := 10.0
const TILT_SPEED := 5.0
const WALL_RUN_COOLDOWN := 0.2

var camera_tilt := 0.0

func _physics_process(delta):
	# Check if touching a wall
	is_touching_left_wall = left_wall_check.is_colliding()
	is_touching_right_wall = right_wall_check.is_colliding()

	# Update wall normal
	if is_touching_left_wall:
		wall_normal = left_wall_check.get_collision_normal()
	elif is_touching_right_wall:
		wall_normal = right_wall_check.get_collision_normal()
	else:
		wall_normal = Vector3.ZERO

	# Handle Wall Run Logic
	if is_wall_running:
		continue_wall_run(delta)
	elif (is_touching_left_wall or is_touching_right_wall) and PLAYER.velocity.length() >= MIN_SPEED_REQUIRED and not PLAYER.wall_run_disabled:
		start_wall_run()

	# Smooth Camera Tilt
	if is_wall_running:
		if is_touching_left_wall:
			camera_tilt = lerp(camera_tilt, -MAX_TILT, delta * TILT_SPEED)
		elif is_touching_right_wall:
			camera_tilt = lerp(camera_tilt, MAX_TILT, delta * TILT_SPEED)
	else:
		camera_tilt = lerp(camera_tilt, 0.0, delta * TILT_SPEED)

	camera.rotation_degrees.z = camera_tilt

func start_wall_run():
	if PLAYER.wall_run_disabled:
		return

	is_wall_running = true
	PLAYER.velocity.y = 0  # Cancel gravity
	
	if wall_normal == Vector3.ZERO:
		print_debug("🚨 ERROR: Wall normal is ZERO!")
		stop_wall_run()
		return

	var wall_forward = wall_normal.cross(Vector3.UP).normalized()
	
	# Ensure the direction is correct
	if (PLAYER.forward_direction - wall_forward).length() > (PLAYER.forward_direction - -wall_forward).length():
		wall_forward = -wall_forward

	wall_run_direction = wall_forward
	PLAYER.velocity = wall_run_direction * WALL_RUN_SPEED
	
	print_debug("\n=== Wall Run Started! ===",
		"\nVelocity:", PLAYER.velocity,
		"\nWall Normal:", wall_normal,
		"\nRun Direction:", wall_run_direction)

func continue_wall_run(delta):
	var forward_speed = max(PLAYER.velocity.dot(wall_run_direction), WALL_RUN_SPEED)
	PLAYER.velocity = wall_run_direction * forward_speed
	PLAYER.velocity.y = 0  # No vertical movement

	# Stop if not touching a wall
	if not is_touching_left_wall and not is_touching_right_wall:
		stop_wall_run()

func stop_wall_run():
	if not is_wall_running:
		return

	is_wall_running = false
	PLAYER.velocity.y = -5  # Slight drop effect
	transition.emit("FallingPlayerState")

	print_debug("\n=== Wall Run Stopped! ===", 
		"\nVelocity:", PLAYER.velocity)

func _input(event):
	if Input.is_action_just_pressed("jump") and is_wall_running:
		wall_jump()

func wall_jump():
	if wall_normal == Vector3.ZERO:
		print_debug("\n=== Wall Jump Failed: No valid wall normal ===")
		return

	# In your coordinate system:
	# - Y axis = forward/backward and up (if you haven't rotated the world, Y is typically up).
	# - Z axis = left/right.
	#
	# Here we want to push the player horizontally away from the wall using the Z component.
	# We'll use the wall normal's Z value to determine the push, while adding an upward boost
	# and preserving some forward momentum along the Y-axis (which you use for forward movement).
	
	# Calculate horizontal push along the Z axis:
	var horizontal_push = -wall_normal.z * WALL_JUMP_FORCE * 2.0   # Increase multiplier as needed
	
	# Vertical boost remains in the Y direction:
	var vertical_boost = Vector3.UP * WALL_JUMP_VERTICAL_BOOST
	
	# Forward momentum from player's current forward direction.
	# Assume that PLAYER.forward_direction is set such that its Y component is the forward component.
	# We take only the Y component (and set X and Z to zero) to add forward motion.
	var forward_momentum = Vector3(0, PLAYER.forward_direction.y, 0) * WALL_RUN_SPEED * 0.6

	# Combine: No X movement, vertical boost on Y, and horizontal push on Z.
	var jump_direction = Vector3(0, vertical_boost.y, horizontal_push) + forward_momentum

	PLAYER.velocity = jump_direction

	stop_wall_run()
	PLAYER.wall_run_disabled = true  
	await get_tree().create_timer(WALL_RUN_COOLDOWN)
	PLAYER.wall_run_disabled = false  

	transition.emit("FallingPlayerState")

	print_debug("\n=== Horizontal Wall Jump! ===",
		"\nVelocity After:", PLAYER.velocity,
		"\nWall Normal:", wall_normal,
		"\nJump Direction:", jump_direction)

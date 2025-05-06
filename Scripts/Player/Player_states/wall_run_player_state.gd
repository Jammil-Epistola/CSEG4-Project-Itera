class_name WallRunPlayerState extends PlayerMovementState

@onready var left_wall_check = $"../../WallCheck/LeftWallCheck"
@onready var right_wall_check = $"../../WallCheck/RightWallCheck"
@onready var camera = $"../../Head/Camera3D"

# Wall Running Variables
var is_wall_running = false
var is_touching_left_wall = false
var is_touching_right_wall = false
var wall_normal := Vector3.ZERO
var wall_run_direction := Vector3.ZERO
var wall_run_timer := 0.0

# Wall Run Settings
const WALL_RUN_SPEED := 10.0
const WALL_GRAVITY := 2.0
const MIN_SPEED_REQUIRED := 9.0
const MAX_WALL_RUN_TIME := 2.0
const WALL_CLIMB_SPEED := 3.0
const GRAVITY_COUNTER_FORCE := 10.0

# Camera Settings
const MAX_TILT := 10.0
const TILT_SPEED := 5.0
var camera_tilt := 0.0

func _physics_process(delta):
	# Check for walls
	is_touching_left_wall = left_wall_check.is_colliding()
	is_touching_right_wall = right_wall_check.is_colliding()
	
	# Update wall touching flags in Player class
	PLAYER.is_touching_left_wall = is_touching_left_wall
	PLAYER.is_touching_right_wall = is_touching_right_wall

	# Update wall normal
	if is_touching_left_wall:
		wall_normal = left_wall_check.get_collision_normal()
		PLAYER.last_wall_normal = wall_normal
	elif is_touching_right_wall:
		wall_normal = right_wall_check.get_collision_normal()
		PLAYER.last_wall_normal = wall_normal
	else:
		if not is_wall_running:
			wall_normal = Vector3.ZERO

	# Handle wall run logic
	if is_wall_running:
		continue_wall_run(delta)
	elif (is_touching_left_wall or is_touching_right_wall) and PLAYER.velocity.length() >= MIN_SPEED_REQUIRED and not PLAYER.wall_run_disabled and not PLAYER.is_wall_jumping:
		start_wall_run()

	# Smooth Camera Tilt
	if is_wall_running:
		camera_tilt = lerp(camera_tilt, -MAX_TILT if is_touching_left_wall else MAX_TILT, delta * TILT_SPEED)
	else:
		camera_tilt = lerp(camera_tilt, 0.0, delta * TILT_SPEED)

	camera.rotation_degrees.z = camera_tilt

func start_wall_run():
	if PLAYER.wall_run_disabled or is_wall_running:
		return

	is_wall_running = true
	wall_run_timer = MAX_WALL_RUN_TIME
	PLAYER.velocity.y = 0  # Reset vertical velocity

	if wall_normal == Vector3.ZERO:
		print_debug("🚨 Wall Run Failed: Invalid wall normal")
		stop_wall_run()
		return

	# Calculate wall forward direction (perpendicular to wall normal)
	var wall_forward = wall_normal.cross(Vector3.UP).normalized()
	
	# Ensure the direction aligns with player's movement
	var dot_product = wall_forward.dot(PLAYER.forward_direction)
	if dot_product < 0:
		wall_forward = -wall_forward

	wall_run_direction = wall_forward
	PLAYER.velocity = wall_run_direction * WALL_RUN_SPEED

	print_debug("🏃 Wall Run Started")

func continue_wall_run(delta):
	# Update wall run timer
	wall_run_timer -= delta
	if wall_run_timer <= 0:
		stop_wall_run()
		return

	# Get input for wall climbing
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var is_climbing = Input.is_action_pressed("sprint")
	var is_descending = Input.is_action_pressed("crouch")

	# Maintain speed along the wall
	var forward_speed = max(PLAYER.velocity.dot(wall_run_direction), WALL_RUN_SPEED)
	PLAYER.velocity = wall_run_direction * forward_speed
	
	# Handle wall climbing/descending
	if is_climbing:
		PLAYER.velocity.y = WALL_CLIMB_SPEED
	elif is_descending:
		PLAYER.velocity.y = -WALL_CLIMB_SPEED
	else:
		# Apply reduced gravity
		PLAYER.velocity.y -= WALL_GRAVITY * delta

	# Apply gravity counter force
	PLAYER.velocity.y += GRAVITY_COUNTER_FORCE * delta

	# Stop if no longer touching a wall
	if not is_touching_left_wall and not is_touching_right_wall:
		stop_wall_run()

func stop_wall_run():
	if not is_wall_running:
		return

	is_wall_running = false
	PLAYER.is_wall_running = false
	wall_run_timer = 0.0

	# Store the last valid wall normal
	if wall_normal != Vector3.ZERO:
		PLAYER.last_wall_normal = wall_normal
		print_debug("🛑 Wall Run Stopped")
	else:
		print_debug("⚠️ Wall Run Stopped: Invalid wall normal")

	# Apply a small downward velocity
	PLAYER.velocity.y = -5
	transition.emit("FallingPlayerState")

func _input(event):
	if event.is_action_pressed("jump") and is_wall_running:
		# Ensure we have a valid wall normal before transitioning
		if wall_normal != Vector3.ZERO:
			PLAYER.last_wall_normal = wall_normal
			print_debug("🦘 Wall Jump Triggered")
			# Stop wall running before transitioning
			is_wall_running = false
			PLAYER.is_wall_running = false
			transition.emit("WallJumpPlayerState")
		else:
			print_debug("⚠️ Wall Jump Failed: Invalid wall normal")

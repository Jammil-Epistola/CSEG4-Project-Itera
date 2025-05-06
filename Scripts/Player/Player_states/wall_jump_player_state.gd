class_name WallJumpPlayerState extends PlayerMovementState

# Wall Jump Settings
const WALL_JUMP_UP_FORCE := 10.0
const WALL_JUMP_SIDE_FORCE := 8.0
const WALL_JUMP_FORWARD_FORCE := 10.0
const WALL_JUMP_COOLDOWN := 0.3

var jump_direction := Vector3.ZERO
var exit_wall_timer := 0.0
var is_exiting_wall := false

func enter(previous_state) -> void:
	# Ensure last_wall_normal is used correctly
	if PLAYER.last_wall_normal == Vector3.ZERO:
		print_debug("🚨 Wall Jump Failed: No valid wall normal")
		transition.emit("FallingPlayerState")
		return

	# Set the wall normal from the last valid value
	PLAYER.wall_normal = PLAYER.last_wall_normal

	# Reset vertical velocity before jump
	PLAYER.velocity.y = 0

	# Calculate wall forward direction (perpendicular to wall normal)
	var wall_forward = PLAYER.wall_normal.cross(Vector3.UP).normalized()
	
	# Determine jump direction based on wall side
	var horizontal_direction = Vector3.ZERO
	
	# If on right wall, jump left (away from wall)
	if PLAYER.is_touching_right_wall:
		horizontal_direction = Vector3.LEFT
	# If on left wall, jump right (away from wall)
	elif PLAYER.is_touching_left_wall:
		horizontal_direction = Vector3.RIGHT

	# Compute jump direction
	var up_force = Vector3.UP * WALL_JUMP_UP_FORCE
	var side_force = horizontal_direction * WALL_JUMP_SIDE_FORCE
	var forward_force = wall_forward * WALL_JUMP_FORWARD_FORCE

	# Combine all forces
	jump_direction = up_force + side_force + forward_force

	# Apply jump velocity
	PLAYER.velocity = jump_direction

	# Set wall jumping flag and start exit timer
	PLAYER.is_wall_jumping = true
	is_exiting_wall = true
	exit_wall_timer = WALL_JUMP_COOLDOWN

	# Disable wall-running temporarily
	PLAYER.wall_run_disabled = true
	PLAYER.is_wall_running = false

	print_debug("🦘 Wall Jump Executed")

func update(delta):
	# Update exit wall timer
	if is_exiting_wall:
		exit_wall_timer -= delta
		if exit_wall_timer <= 0:
			is_exiting_wall = false
			PLAYER.wall_run_disabled = false
			PLAYER.is_wall_jumping = false
			transition.emit("FallingPlayerState")

	# Apply gravity during wall jump
	PLAYER.update_gravity(delta)
	PLAYER.update_velocity()

func exit():
	# Ensure wall jumping flag is reset when leaving the state
	PLAYER.is_wall_jumping = false
	PLAYER.wall_run_disabled = false

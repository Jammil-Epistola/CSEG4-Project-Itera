extends CharacterBody3D

const ACCEL = 90
const FRICTION = 0.85
const JUMP_VELOCITY = 13
const WALL_JUMP_VELOCITY =  50

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const FLOOR = 0
const WALL = 1
const AIR = 2
var current_state := AIR

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, $SpringArm3D.rotation.y)
	if direction:
		velocity.x = direction.x * ACCEL * delta
		velocity.z = direction.z * ACCEL * delta
			
	check_jump()
	move_and_slide()
	update_state()
	
	velocity.x *= FRICTION
	velocity.y *= FRICTION

func update_state():
	if is_on_wall_only():
		current_state = WALL
	elif is_on_floor():
		current_state = FLOOR
	else:
		current_state = AIR

func check_jump():
	if Input.is_action_just_pressed("jump"):
		if current_state == FLOOR:
			velocity.y = JUMP_VELOCITY
		if current_state == WALL:
			velocity = get_wall_normal() * WALL_JUMP_VELOCITY
			velocity.y += JUMP_VELOCITY * 0.7

func _input(event):
	if event is InputEventMouseMotion:
		$SpringArm3D.rotation.y -= event.relative.x * 0.005
		$SpringArm3D.rotation.x += event.relative.y * -0.005
	

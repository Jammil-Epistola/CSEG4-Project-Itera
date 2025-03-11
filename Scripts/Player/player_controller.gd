class_name Player extends CharacterBody3D

@export var ACCELERATION: float = 0.1
@export var DECELERATION: float = 0.25

# Mouse Rotation
@export var MOUSE_SENSITIVITY : float = 0.10
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)

@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST: Node3D

# Head Bobbing Variables
@export var BOB_FREQ: float = 2.0
@export var BOB_AMP: float = 0.08
var t_bob: float = 0.0

#WallRun
var wall_normal: Vector3 = Vector3.ZERO
var is_wall_running: bool = false
var wall_run_disabled: bool = false

# Mouse Input
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

var _current_rotation : float
var forward_direction := Vector3.ZERO

# Gravity
var gravity = 9.8

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY

func _input(event):
	# Exit Game
	if event.is_action_pressed("exit"):
		get_tree().quit()
 
func _update_camera(delta):
	_current_rotation = _rotation_input
	# Rotate camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	_camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():
	Global.player = self
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CROUCH_SHAPECAST.add_exception($".")
	ANIMATIONPLAYER = $AnimationPlayer
	

func _physics_process(delta):
	# Debug Properties
	Global.debug.add_property("FPS", Global.debug.frames_per_second, 1)
	Global.debug.add_property("Velocity","%.2f" % velocity.length(), 2)
	Global.debug.add_property("Mouse Rotation", _mouse_rotation, 3)
	Global.debug.add_property("Y Velocity", velocity.y, 4)
	if $PlayerStateMachine.CURRENT_STATE:
		Global.debug.add_property("State", $PlayerStateMachine.CURRENT_STATE.name, 5)
		
	# Camera
	_update_camera(delta)
	
	# Apply Gravity`
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Head Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	CAMERA_CONTROLLER.transform.origin = _headbob(t_bob)

# Head Bobbing
func _headbob(time: float) -> Vector3:
	# Disable head bobbing when sliding
	if $PlayerStateMachine.CURRENT_STATE is SlidingPlayerState:
		return Vector3.ZERO  # No movement when sliding
		
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

# Gravity Update
func update_gravity(delta) -> void:
	velocity.y -= gravity * delta

func update_input(speed: float, acceleration: float, deceleration: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	forward_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()  # Store direction

	if forward_direction != Vector3.ZERO:
		velocity.x = lerp(velocity.x, forward_direction.x * speed, acceleration)
		velocity.z = lerp(velocity.z, forward_direction.z * speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration)
		velocity.z = move_toward(velocity.z, 0, deceleration)

# Apply Velocity
func update_velocity() -> void:
	move_and_slide()

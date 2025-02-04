extends CharacterBody3D

var _speed
@export var WALK_SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export_range(5,10,0.1) var CROUCH_SPEED : float = 7.0
#Mouse Rotation
@export var MOUSE_SENSITIVITY : float = 0.10
@export var TILT_LOWER_LIMIT := deg_to_rad(-90.0)
@export var TILT_UPPER_LIMIT := deg_to_rad(90.0)

@export var CAMERA_CONTROLLER : Camera3D
@export var ANIMATIONPLAYER : AnimationPlayer
@export var CROUCH_SHAPECAST : Node3D


# Head Bobbing Variables
@export var BOB_FREQ: float = 2.0
@export var BOB_AMP: float = 0.08
var t_bob: float = 0.0

#Getting Mouse Input
var _mouse_input : bool = false
var _mouse_rotation : Vector3
var _rotation_input : float
var _tilt_input : float
var _player_rotation : Vector3
var _camera_rotation : Vector3

#Crouching
var _is_crouching : bool = false

#Get gravity to be synced with RigidBody Node
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * MOUSE_SENSITIVITY
		_tilt_input = -event.relative.y * MOUSE_SENSITIVITY
		print(Vector2(_rotation_input,_tilt_input))

func _input(event):
	#Exit Game
	if event.is_action_pressed("exit"):
		get_tree().quit()
	
	#Crouch
	if event.is_action_pressed("crouch"):
		toggle_crouch()

func _update_camera(delta):
	#Rotate camera using euler rotation
	_mouse_rotation.x += _tilt_input * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, TILT_LOWER_LIMIT, TILT_UPPER_LIMIT)
	_mouse_rotation.y += _rotation_input * delta
	
	_player_rotation = Vector3(0.0,_mouse_rotation.y,0.0)
	_camera_rotation = Vector3(_mouse_rotation.x,0.0,0.0)
	
	CAMERA_CONTROLLER.transform.basis = Basis.from_euler(_camera_rotation)
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	CAMERA_CONTROLLER.rotation.z = 0.0
	
	_rotation_input = 0.0
	_tilt_input = 0.0
	
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#add crouch check collison exception for CharBody3D node
	CROUCH_SHAPECAST.add_exception($".")
	_speed = WALK_SPEED
	
func _physics_process(delta):
	#Calling Debug Properties
	Global.debug.add_property("FPS", Global.debug.frames_per_second, 1)
	Global.debug.add_property("Movement Speed",_speed,2)
	Global.debug.add_property("Mouse Rotation",_mouse_rotation,3)
	
	#Camera
	_update_camera(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * _speed
		velocity.z = direction.z * _speed
	else:
		velocity.x = move_toward(velocity.x, 0, _speed)
		velocity.z = move_toward(velocity.z, 0, _speed)
	
	# Head Bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	CAMERA_CONTROLLER.transform.origin = _headbob(t_bob)
		
	move_and_slide()

#toggle crouch
func toggle_crouch():
	if _is_crouching == true and CROUCH_SHAPECAST.is_colliding() == false:
		ANIMATIONPLAYER.play("Crouch", -1, -CROUCH_SPEED, true)
	elif _is_crouching == false:
		ANIMATIONPLAYER.play("Crouch", -1, CROUCH_SPEED)
	_is_crouching = !_is_crouching
		
#Head Bobbing
func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

extends CharacterBody3D

@export var player_health_max: float = 50.0
@export var player_health_current: float = player_health_max

var player_speed_current: float = 0.0
@export var player_speed_walk_max: float = 5.0
@export var player_speed_sprint_max: float = player_speed_walk_max * 2.0
@export var player_jump_speed_modifier: float = 0.8
@export var player_walk_accel_rate: float = 4.0
@export var player_sprint_accel_rate: float = 9.0
@export var player_decel_rate: float = 14.0
@export var player_jump_decel_rate: float = 10.0
@export var player_rotation_rate: float = 9.0
@export var target_cam_bias_default: float = 0.3
@export var target_cam_bias_additive: float = 0.2
var target_cam_bias: float = target_cam_bias_default
@export var cam_lerp_rate: float = 5.0
@export var tracking_range: float = 6.0
@export var jump_velocity: float = 5.0
@export var jump_velocity_multiplier: float = 1.25
@export var root_motion_multiplier: float = 4.0

var has_direction: bool = false
var is_jumping: bool = false

var current_oneshot_anim: String
var targeting: bool = false
var tracking: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var gravity_multiplier: float = 1.5

@onready var player_mesh: Node3D = $MeshInstance3D
@onready var player_cam: Camera3D = $SpringArm3D/PlayerCam

var viewport_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
var viewport_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
var viewport_wh: Vector2 = Vector2(viewport_width, viewport_height)

@export var mouse_sensitivity: float = 2.5
@export var joystick_sensitivity: float = 3.0

var overlapping_objects: Array[Node3D]
var targeted_object: Node3D = null

enum PlayerMovementState {
	IDLE = 0,
	WALK = 1,
	SPRINT = 2,
	DODGE = 3,
	ATTACK = 4,
	DAMAGED = 5,
	STUN = 6,
	CHAT = 7,
	DEAD = 8
}

var movement_state: PlayerMovementState = PlayerMovementState.IDLE
#var blending_movement_state: bool = false

func _ready():
	# capture mouse movement for camera navigation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float):
	# only do the below movements if already in movement states 0-2.
	if movement_state < 3:
		calculate_player_lateral_movement(delta)
		apply_jump_and_gravity(delta)
	
	# camera movement w/ controller
	rotate_cam_joypad(delta)
	
	move_and_slide()

func _input(event):
	# camera movement w/ mouse
	rotate_cam_kb_m(event)

func rotate_player(delta: float) -> void:
	# player mesh rotation relative to camera. Note: the entire Player never rotates: only the spring arm or the mesh.
	if $MeshInstance3D.rotation.y != $SpringArm3D.rotation.y:
		$MeshInstance3D.rotation.y = lerp_angle($MeshInstance3D.rotation.y, atan2(velocity.x, velocity.z), player_rotation_rate * delta)

func apply_jump_and_gravity(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta
	# hitting the ground
	else:
		if is_jumping:
			is_jumping = false
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			is_jumping = true
			velocity.y = jump_velocity * jump_velocity_multiplier

func apply_only_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

func calculate_player_lateral_movement(delta: float) -> void:
	# Get the input direction.
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	
	# set dir to always face forward, relative to where camera spring arm is positioned.
	# also remove vertical camera data from both x & z axis Vec3's to ensure cam height doesn't affect speed.
	var direction_x: Vector3 = $SpringArm3D.transform.basis.x
	direction_x.y = 0
	direction_x = direction_x.normalized() * input_dir.x # x-axis input == 3D x axis (left/right)
	
	var direction_z: Vector3 = $SpringArm3D.transform.basis.z
	direction_z.y = 0
	direction_z = direction_z.normalized() * input_dir.y # y-axis input == 3D z axis (forward/back)
	
	# recombine separated direction vectors back into one.
	var direction: Vector3 = direction_x + direction_z
	has_direction = true if direction != Vector3() else false
	
	# determine if the player will be walking or sprinting.
	if has_direction:
		determine_player_movement_speed(delta)
		apply_player_lateral_movement(delta, direction)
	else:
		stop_player_movement(delta)

func determine_player_movement_speed(delta: float) -> void:
	if Input.is_action_just_pressed("sprint"):
		if movement_state == PlayerMovementState.WALK:
			movement_state = PlayerMovementState.SPRINT
		else:
			movement_state = PlayerMovementState.WALK
	
	if movement_state == PlayerMovementState.IDLE || movement_state == PlayerMovementState.WALK:
		player_speed_current = player_speed_walk_max
	elif movement_state == PlayerMovementState.SPRINT:
		player_speed_current = player_speed_sprint_max

func apply_player_lateral_movement(delta: float, dir: Vector3) -> void:
	if !is_jumping:
		velocity.x = dir.x * player_speed_current
		velocity.z = dir.z * player_speed_current
	else:
		var player_speed_jump: float = player_speed_current * player_jump_speed_modifier
		velocity.x = dir.x * player_speed_jump
		velocity.z = dir.z * player_speed_jump

func stop_player_movement(delta: float) -> void:
	# update movement state
	movement_state = PlayerMovementState.IDLE
	player_speed_current = 0
	velocity.x = 0
	velocity.z = 0

# determine how to move when applying root motion.
func handle_root_motion(delta: float, rm_multiplier: float = root_motion_multiplier, lateral_only: bool = false) -> void:
	pass

func rotate_cam_kb_m(event) -> void:
	# mouse spring arm rotation
	if (event is InputEventMouseMotion):
		# mouse x movement (in 2D monitor space) becomes spring arm rotation in 3D space around the Y axis - left/right rotation.
		$SpringArm3D.rotation.y -= event.relative.x / 1000 * mouse_sensitivity
		# mouse y movement (in 2D monitor space) becomes spring arm rotation in 3D space around the X axis - up/down rotation.
		$SpringArm3D.rotation.x -= event.relative.y / 1000 * mouse_sensitivity
		$SpringArm3D.rotation.x = clamp($SpringArm3D.rotation.x, -1.4, 0.3) # clamp the value to avoid full rotation.


func rotate_cam_joypad(delta: float) -> void:
	pass
	# controller spring arm rotation
#	$SpringArm3D.rotation.y -= Input.get_action_strength("camera_left_joystick") * -joystick_sensitivity * delta
#	$SpringArm3D.rotation.y -= Input.get_action_strength("camera_right_joystick") * joystick_sensitivity * delta
#
#	$SpringArm3D.rotation.x = Input.get_action_strength("camera_up_joystick") * -joystick_sensitivity * delta
#	$SpringArm3D.rotation.x = Input.get_action_strength("camera_down_joystick") * joystick_sensitivity * delta
#	$SpringArm3D.rotation.x = clamp($SpringArm3D.rotation.x, -1.4, 0.3)

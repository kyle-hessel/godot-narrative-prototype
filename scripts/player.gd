extends CharacterBody3D

@export var player_health_max: float = 50.0
@export var player_health_current: float = player_health_max

var player_speed_current: float = 0.0
@export var player_speed_walk_max: float = 6.0
@export var player_speed_sprint_max: float = player_speed_walk_max * 3.0
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

var current_combat_action: String = "none"

var available_combat_actions: Array[String] = [ "big_swing", "pummel", "crater", "ult_explode" ]

# combat actions dictionary w/ defaults
var combat_actions = {
	"action1": available_combat_actions[0],
	"action2": available_combat_actions[1],
	"action3": available_combat_actions[2],
	"action4": available_combat_actions[3],
}

enum PlayerMovementState {
	IDLE = 0,
	WALK = 1,
	SPRINT = 2,
	ATTACK = 3,
	DODGE = 4,
	STUN = 5,
	CHAT = 6,
	DEAD = 7
}

var movement_state: PlayerMovementState = PlayerMovementState.IDLE
#var blending_movement_state: bool = false

func _ready():
	# capture mouse movement for camera navigation
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$SpringArm3D.add_excluded_object(self)

func _physics_process(delta: float) -> void:
	# only do the below movements if already in movement states 0-2.
	if movement_state < 3:
		calculate_player_lateral_movement(delta)
		apply_jump_and_gravity(delta)
	
	# camera movement w/ controller
	rotate_cam_joypad(delta)
	
	# collisions
	move_and_slide()

func _input(event):
	# camera movement w/ mouse
	rotate_cam_kb_m(event)
	
	# handle what happens when the player presses different combat actions in combat.
	# using 'event.' instead of 'Input.' for better input event buffering.
	interpret_combat_action_handles(event)

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
		if movement_state == PlayerMovementState.WALK || movement_state == PlayerMovementState.IDLE:
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
	# controller spring arm rotation
	$SpringArm3D.rotation.y -= Input.get_action_strength("camera_left_joystick") * -joystick_sensitivity * delta
	$SpringArm3D.rotation.y -= Input.get_action_strength("camera_right_joystick") * joystick_sensitivity * delta

	$SpringArm3D.rotation.x -= Input.get_action_strength("camera_up_joystick") * -joystick_sensitivity * delta
	$SpringArm3D.rotation.x -= Input.get_action_strength("camera_down_joystick") * joystick_sensitivity * delta
	$SpringArm3D.rotation.x = clamp($SpringArm3D.rotation.x, -1.4, 0.3)

# translates button presses to appropriate assigned combat actions using value fetching from the combat_actions dictionary,
# and sends this off to handle_combat_action to begin executing the appropriate action.
func interpret_combat_action_handles(event) -> void:
	if movement_state < 4:
		# determine which combat action to execute based on player assignments
		if event.is_action_pressed("combat_action1"):
			handle_combat_action(combat_actions["action1"])
			
		elif event.is_action_pressed("combat_action2"):
			handle_combat_action(combat_actions["action2"])
			
		elif event.is_action_pressed("combat_action3"):
			handle_combat_action(combat_actions["action3"])
			
		elif event.is_action_pressed("combat_action4"):
			handle_combat_action(combat_actions["action4"])

# funnel inputted combat action into the appropriate function call.
func handle_combat_action(command: String) -> void:
	match command:
		"big_swing":
			combat_action_big_swing()
		"pummel":
			combat_action_pummel()
		"crater":
			combat_action_crater()
		"ult_explode":
			combat_action_ult_explode()
		_:
			print("Not a valid combat action.")

# name subject to change
func combat_action_big_swing() -> void:
	print("big swing!")

# name subject to change
func combat_action_pummel() -> void:
	print("pummel!")

# name subject to change
func combat_action_crater() -> void:
	print("crater!")

# name subject to change
func combat_action_ult_explode() -> void:
	print("ult: explode!")

### HELPER FUNCTIONS
func tween_val(object: Node, property: NodePath, final_val: Variant, duration: float, trans_type: Tween.TransitionType = Tween.TRANS_LINEAR, ease_type: Tween.EaseType = Tween.EASE_IN_OUT, parallel: bool = true):
	var tween: Tween = get_tree().create_tween()
	tween.stop()
	tween.set_trans(trans_type)
	tween.set_ease(ease_type)
	tween.set_parallel(parallel)
	tween.tween_property(object, property, final_val, duration)
	tween.play()

# generic, reimplemented from engine source
func looking_at_gd(target: Vector3, up: Vector3) -> Basis:
	var v_z: Vector3 = -target.normalized()
	var v_x: Vector3 = up.cross(v_z)
	
	v_x.normalized()
	var v_y: Vector3 = v_z.cross(v_x)
	
	var v_basis: Basis = Basis(v_x, v_y, v_z)
	return v_basis
	
# for meshes, such as player (minor modification of looking_at)
func facing_object(target: Vector3, up: Vector3)-> Basis:
	var v_z: Vector3 = target.normalized()
	var v_x: Vector3 = up.cross(v_z)
	
	v_x.normalized()
	var v_y: Vector3 = v_z.cross(v_x)
	
	var v_basis: Basis = Basis(v_x, v_y, v_z)
	return v_basis
	
# generic, reimplemented from engine source
func look_at_from_pos_gd(obj: Node3D, pos: Vector3, target: Vector3, up: Vector3) -> void:
	var lookat: Transform3D = Transform3D(looking_at_gd(target - pos, up), pos)
	var original_scale: Vector3 = obj.scale
	obj.global_transform = lookat
	obj.scale = original_scale
	
# generic, reimplemented from engine source
func look_at_gd(obj: Node3D, target: Vector3, up: Vector3) -> void:
	var origin: Vector3 = obj.global_transform.origin
	look_at_from_pos_gd(obj, origin, target, up)
	
# for camera (adds lerp to default look_at_from_position)
func look_at_from_pos_lerp(obj: Node3D, pos: Vector3, target: Vector3, up: Vector3, delta: float) -> void:
	var lookat: Transform3D = Transform3D(looking_at_gd(target - pos, up), pos)
	var original_scale: Vector3 = obj.scale
	#obj.global_transform = lerp(obj.global_transform, lookat, player_rotation_rate * delta)
	obj.global_transform = obj.global_transform.interpolate_with(lookat, cam_lerp_rate * delta)
	#obj.global_transform = lookat
	obj.scale = original_scale
	
# for meshes, such as player (minor modification of looking_at_from_position)
func facing_object_from_pos_lerp(obj: Node3D, pos: Vector3, target: Vector3, up: Vector3, delta: float) -> void:
	var lookat: Transform3D = Transform3D(facing_object(target - pos, up), pos)
	var original_scale: Vector3 = obj.scale
	#obj.global_transform = lerp(obj.global_transform, lookat, player_rotation_rate * delta)
	obj.global_transform = obj.global_transform.interpolate_with(lookat, player_rotation_rate * delta)
	#obj.global_transform = lookat
	obj.scale = original_scale

# for camera (adds lerp to default look_at)
func look_at_lerp(obj: Node3D, target: Vector3, up: Vector3, delta: float) -> void:
	var origin: Vector3 = obj.global_transform.origin
	look_at_from_pos_lerp(obj, origin, target, up, delta)

# for meshes, such as player (minor modification of look_at)
func face_object_lerp(obj: Node3D, target: Vector3, up: Vector3, delta: float) -> void:
	var origin: Vector3 = obj.global_transform.origin
	facing_object_from_pos_lerp(obj, origin, target, up, delta)

# returns front, back, left, or right.
func find_relative_direction(from: Vector3, to: Vector3) -> String:
	var angle_diff: float = rad_to_deg(from.signed_angle_to(to, Vector3.UP))
	#print("angle diff: ", angle_diff)
							
	if angle_diff < 45.0 && angle_diff >= -45.0:
		return "back"
	elif angle_diff < -45.0 && angle_diff >= -135.0:
		return "left"
	elif angle_diff < 135.0 && angle_diff >= 45.0:
		return "right"
	elif angle_diff >= 135.0 || angle_diff < -135.0:
		return "front"
	else:
		return "?"

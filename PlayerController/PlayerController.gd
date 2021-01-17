extends KinematicBody

######-Variables-##############################################################

# Camera
var camera_angle = 0
export var mouse_sensitivity = 0.1
# Movement
var velocity = Vector3()
var direction = Vector3()
var playerFlyMode = 0
var zoommode = 1
var crouchmode = 1
var jump_height = 20
var gravity = -29.8
# Flying Constants
const FLY_SPEED = 10
const FLY_ACCEL = 1
const MAX_SPEED = 10
const MAX_RUNNING_SPEED = 20
const ACCEL = 10
const DEACCEL = 10


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	playerFlyMode = 1
	pass


func _physics_process(delta):
	match playerFlyMode:
		0:
			fly(delta)
		1:
			walk(delta)



func _input(event):
	if event is InputEventMouseMotion:
		$Head.rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
				$Head/Camera.rotate_x(deg2rad(change))
				camera_angle += change
	
	if Input.is_action_pressed("switch"):
		playerFlyMode = int(not bool(playerFlyMode))
	if Input.is_action_pressed("exit"):
		# Loads the Main Menu if the ESC key is pressed
		get_tree().change_scene("res://Scenes/menu.tscn")
	# Zooms in the camera view
	if Input.is_action_just_pressed("zoom"):
		$Head/Camera.fov = 20 if zoommode == 1 else 70
		mouse_sensitivity = 0.05 if zoommode == 1 else 0.2
		zoommode = int(not bool(zoommode))
		
# Walking and Sprinting
func walk(delta):
	direction = get_direction()
	# Apply Gravity
	velocity.y += gravity * delta
	
	var temp_velocity = velocity 
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("move_sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	var target = direction * speed
	# interpolation
	temp_velocity = temp_velocity.linear_interpolate(target, ACCEL * delta)
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
	# Move
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))


func fly(delta):
	direction = get_direction()
	
	var target
	if Input.is_action_pressed("move_sprint"):
		target = direction * FLY_SPEED * 12
	else:
		target = direction * FLY_SPEED
	
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	
	move_and_slide(velocity)


func get_direction():
	# Input
	direction = Vector3()	
	var aim = $Head/Camera.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
			direction -= aim.z
	if Input.is_action_pressed("move_backward"):
			direction += aim.z
	if Input.is_action_pressed("move_left"):
			direction -= aim.x
	if Input.is_action_pressed("move_right"):
			direction += aim.x
	if Input.is_action_pressed("move_up"):
			direction += aim.y * 0.1
	if Input.is_action_pressed("move_down"):
			direction -= aim.y * 0.1
	
	return direction.normalized()



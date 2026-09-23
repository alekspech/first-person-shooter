extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const SENSETIVITY = 0.003

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0
const BASE_FOV = 90
const CHANGE_FOV = 1.5

var bullet_scene = load("res://Scenes/bullet.tscn")
var bullet 
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var weapon_animation = $Head/Camera3D/WeaponPosition/USP/AnimationPlayer
@onready var weapon_barrel = $Head/Camera3D/WeaponPosition/USP/RayCast3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSETIVITY)
		camera.rotate_x(-event.relative.y * SENSETIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
		
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = 0
			velocity.z = 0
	else:
		velocity.x = lerp(velocity.x , direction.x * speed, delta * 2.0)
		velocity.z = lerp(velocity.z , direction.z * speed, delta * 2.0)
		
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + CHANGE_FOV * velocity_clamped
	camera.fov =  lerp(camera.fov, target_fov, delta * 8)
	if Input.is_action_pressed("shoot"):
		if !weapon_animation.is_playing():
			weapon_animation.play("Shoot")
			bullet = bullet_scene.instantiate()
			bullet.position = weapon_barrel.global_position
			bullet.transform.basis = weapon_barrel.global_transform.basis
			get_parent().add_child(bullet)
	move_and_slide()

func _headbob (time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

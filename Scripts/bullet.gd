extends Node3D
const SPEED = 1400.0
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var direction = Vector3(0,0,-SPEED) * delta
	var movement = transform.basis * direction 
	ray.target_position = direction 
	ray.force_raycast_update()
	if ray.is_colliding():
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
	position += movement  
func _on_timer_timeout() -> void:
	queue_free()

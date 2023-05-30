extends RayCast3D

var aimPosition = Vector3(0,0,0)
@onready var gameCamera = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var mousePosition = gameCamera.get_viewport().get_mouse_position()
	var toPosition = gameCamera.project_local_ray_normal(mousePosition) * 100
	target_position = (toPosition)
	if is_colliding():
		aimPosition = get_collision_point()
	else:
		aimPosition = Vector3(0,0,0)
		
	$"../../TargetNode".global_position = aimPosition
	#print(aimPosition)

	pass



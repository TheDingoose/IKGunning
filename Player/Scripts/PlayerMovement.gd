extends CharacterBody3D

const SPEED = 5.0
var stateMachine

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var gameCamera = get_node("gameCamera")
var isAiming = false
var isShooting = false

#These should be stored in the gun
var shootingCooldown = 0
var currentShootingCooldown = 0
var gunRange = 50
var inAccuracy = .01

signal shotFired(start, end, damage, team, time, target)

func shootGun():
	if not isAiming:
		return
	
	#get aim direction
	var start = $GunAnim/RootNode/Armature/Skeleton3D/GunSlot.global_position
	var bulletDirection = ($TargetNode.global_position - start).normalized()
	
	#accuracy business
	var rand = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
	rand -= rand.project(bulletDirection)
	var end = start + ((lerp(bulletDirection, rand, inAccuracy).normalized() * gunRange))
	
	var TEMPdamage = 10
	#do all the visual shooting business
	
	#draw ray from gun to target
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.exclude = [self, $CollisionShape3D]
	var result = space_state.intersect_ray(query)
	
	if (result.size() > 0):
		shotFired.emit(start, result.position, TEMPdamage, 0, 0, result.collider)
		#if (result.collider.get_type() == "res://Actors/npc_character.tscn"):
		#	pass
	else:
		shotFired.emit(start, end, TEMPdamage, 1, 0, null)
	#call the event for onhit if the ray hits(exact hit position, damage)
	pass

func _ready():
	stateMachine = $GunAnim/AnimationTree.get("parameters/Stater/playback")
	$GunAnim/RootNode/Armature/Skeleton3D/LookIK.start(false)
	$GunAnim/RootNode/Armature/Skeleton3D.physical_bones_start_simulation()
	print($GunAnim/RootNode/Armature/Skeleton3D/PhysicalBone3D.get_simulate_physics())
	
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveUp", "MoveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		stateMachine.travel("Walking")
		direction = direction.rotated(up_direction, gameCamera.rotation.y)
		$GunAnim.rotation.y = Vector3(0,0,1).signed_angle_to(direction, Vector3(0,1,0))
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		stateMachine.travel("Idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
	# SHOOTIN:
	if (currentShootingCooldown <= 0):
		currentShootingCooldown = 0
		if(isShooting and isAiming):
			shootGun()
			isShooting = false
			currentShootingCooldown = shootingCooldown
	else:
		currentShootingCooldown -= delta
	var lookDirection = ($HeadAnchor.global_position - $TargetNode.global_position).normalized()
	$HeadAnchor/HeadTarget.look_at($TargetNode.global_position, Vector3(0,1,0))
	$HeadAnchor/HeadTarget.rotate_object_local(Vector3.UP, PI)
func _input(event):
	if event.is_action_pressed("Shoot"):
		isShooting = true
	if event.is_action_released("Shoot"):
		isShooting = false
		
		
	if event.is_action_pressed("Aim"):
		$GunAnim/RootNode/Armature/Skeleton3D/AimIK.start(false)
		isAiming = true
	if event.is_action_released("Aim"):
		$GunAnim/RootNode/Armature/Skeleton3D/AimIK.stop()
		isAiming = false

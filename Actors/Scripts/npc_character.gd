extends Node3D

var ded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$"../Player".shotFired.connect(_on_player_shot_fired)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_shot_fired(start, end, damage, team, time, target):
	if(target != null):
		if(target.get_owner().get_instance_id() == self.get_instance_id()):
			print(self)
			if(not ded) :
				ded = true
				$RootNode/Armature/Skeleton3D.physical_bones_start_simulation()
				target.apply_impulse((end - start).normalized() * 10,end)
				
			

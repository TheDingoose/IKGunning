extends Control

@export var drawDebug = false
@export var drawAimDebug = false
@export var drawShotDebug = false

@onready var player = get_parent().get_node("Player")
@onready var gameCamera = get_parent().get_node("Player/gameCamera")
@onready var ray = get_parent().get_node("Player/gameCamera/aimRay")

var shots = Array()

class shot:
	var startPos: Vector3
	var endPos: Vector3
	var damage: float
	var team: int
	var timeShot: float



func registerShot(startPos, endPos, damage = 0, team = 0, timeShot = 0):
	var newShot = shot.new()
	newShot.startPos = startPos
	newShot.endPos = endPos
	newShot.damage = damage
	newShot.team = team
	newShot.timeShot = timeShot
	shots.push_back(newShot)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	pass

func _draw():
	if drawDebug:
		if drawAimDebug and ray.is_colliding() and player.isAiming:
			var color = Color(1, 0, 0)
			var start = gameCamera.unproject_position(player.find_child("GunSlot").global_position)
			var end = gameCamera.unproject_position(ray.aimPosition)
			draw_line(start, end, color, 2)
		if drawShotDebug:
			for thisShot in shots:
				var color = Color(max(thisShot.team - 1, 0), min(thisShot.team, 1),1)
				var start = gameCamera.unproject_position(thisShot.startPos)
				var end = gameCamera.unproject_position(thisShot.endPos)
				#Lines are bad when drawing behind camera!
				if(not gameCamera.is_position_behind(thisShot.startPos) and not gameCamera.is_position_behind(thisShot.endPos)):
					draw_line(start, end, color, 2)


func _on_player_shot_fired(start, end, damage, team, time, target):
	print("Shot Registered with args", start, end, damage, team, time, target)
	registerShot(start, end, damage, team, time)
	pass # Replace with function body.

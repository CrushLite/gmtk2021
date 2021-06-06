extends KinematicActor2D
"""
Basic platformer control from Heartbeast 
for the purpose of showing Squash and Stretch
	https://www.youtube.com/watch?v=wETY5_9kFtA
Other platformers are available
"""

const UP = Vector2(0, -1)
const GRAVITY = 35
const SPEED = 500
const JUMP_HEIGHT = -1200

var motion = Vector2()
var motion_previous = Vector2()

signal collided

func _ready():
	_update_query()
	init("res://implementation/DynamicDialogue.json")


func _update_query():
	query.set_fact("motion", motion)
	query.set_fact("motion_previous", motion_previous)
	query.set_fact("speed", motion.length())
	query.set_fact("IsMoving", motion.length() > 0)
	
	

func _physics_process(delta):
#	motion.y += GRAVITY
	
	
	if Input.is_action_pressed("ui_left"):
		motion.x = -SPEED
	elif Input.is_action_pressed("ui_right"):
		motion.x = SPEED
	else:
		motion.x = 0
	
	if Input.is_action_pressed("ui_up"):
		motion.y = -SPEED
	elif Input.is_action_pressed("ui_down"):
		motion.y = SPEED
	else:
		motion.y = 0
	
	motion_previous = motion
	motion = move_and_slide(motion, UP, false)
	
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision:
#			emit_signal("collided", collision)
	
	_update_query()
	if Input.is_action_just_pressed("ui_accept"):
		query.set_fact("concept", "Interact")
		apply_query()





func _on_Area2D_area_entered(area):
	if area.get_parent() is InteractableObject:
		var obj_name = area.get_parent().label
		query.set_fact("%sInArea" % obj_name, true)


func _on_Area2D_area_exited(area):
	if area.get_parent() is InteractableObject:
		var obj_name = area.get_parent().label
		query.set_fact("%sInArea" % obj_name, false)
	

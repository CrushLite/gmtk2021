extends KinematicActor2D

export(String) var ID

func _ready():
	$Area2D.connect("area_entered", self, "_on_Area2D_area_entered")
	$Area2D.connect("area_exited", self, "_on_Area2D_area_exited")
	
	# This should be unique for each actor...maybe
	init("res://implementation/DynamicDialogue.json") 



func _on_Area2D_area_entered(area):
	# check if the area belonged to something with a Query
	if area.get_parent().is_in_group("hasQuery"):
		# add obj in area to the query
		area.get_parent().query.set_fact("%sInArea" % ID, true)


func _on_Area2D_area_exited(area):
	# check if the area belonged to something with a Query
	if area.get_parent().is_in_group("hasQuery"):
		# remove the obj in area from the query
		## could also just set the value to false
		area.get_parent().query.remove_fact("%sInArea" % ID)

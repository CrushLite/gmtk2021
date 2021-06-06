extends Resource
class_name Response


export(String) var name
export(String) var effects
export(String) var target # can be 'any' 'all' 'some_obj_name'
export(float) var new_concept


"""
 "SayHi": {
	  "Effects": "say \"Hello World!\"",
	  "Target": null,
	  "Response": null
	},
"""

func init(_key, _values):
	name = _key
	effects = _values["Effects"]
	target = _values["Target"]
	new_concept = _values["New Concept"]


########### DEBUG ##########

func _to_string():
	return "Response:%s" % [name]

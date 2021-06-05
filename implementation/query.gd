extends Resource
class_name Query

var facts = {}

func get_fact(fact_id):
	assert(has(fact_id), "Attempted to get a non-existant fact")
	return facts[fact_id]

func has(fact_id):
	return fact_id in facts
	
func set_fact(fact_id, value):
#	assert(not has(fact_id))
	facts[fact_id] = value
	
func remove_fact(fact_id):
	assert(has(fact_id))
	facts.erase(fact_id)

	
	
###### DEBUGGING #######

var source # the object that created this query


func _to_string():
	return "|Query|  from: %s : %s" % [source, str(facts)]



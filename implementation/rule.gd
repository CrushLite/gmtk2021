extends Resource
class_name Rule

export(String) var name
export(Array, Resource) var criterion_ids # : Criteria
export(Resource) var response_id # : Response
export(String) var concept
export(String) var source

export(Array, String) var memories # array of essentially meta_vars to change

enum Types { DEFAULT, LIMIT, TIMED }
export(Types) var type
export(float) var type_val # max number for limit, and time in sec for timed

export(bool) var disabled = false

"""
 "PlayerHi": {
	  "Type": "Default",
	  "Criteria": [
		"isPlayer"
	  ],
	  "Response": "SayHi"
	},
"""

func init(key, values):
	name = key
	for c_name in values["Criteria"]:
		criterion_ids.append(c_name)
	for m_name in values["Memories"]:
		memories.append(m_name)
	response_id = values["Response"]
	concept = values["Concept"]
	source = values["Source"]
	type = Types[values["Type"].to_upper()]
	type_val = values["TypeVal"]


func criteria_met(query : Query):
	"""
	Returns true if all criteria are met
	"""
	if disabled:
		print("Tested (Failed) %s: disabled" % [self])
		return false
	# the concept and source must match
	if query.get_fact("concept") != concept:
		print("Tested (Failed) %s: Concept:failed" % [self])
		return false
	if query.get_fact("source") != source:
		print("Tested (Failed) %s: Source:failed" % [self])
		return false
	
	var crit : Criterion = Criterion.new() # kindof awkward
	for c_id in criterion_ids:
#		var crit : Criterion = ChatHandler.criteria_DB[c_id]
		crit.name = c_id
		if not crit.query_passes(query):
			_debug_critera_met(c_id)
			return false
	_debug_critera_met(null)
	
	return true

func get_score():
	return criterion_ids.size()



#func initiate_response(actor_reference):
#	var re : Response = ChatHandler.responses_DB[response_id]
#	re.go(actor_reference)

########### DEBUG ##########

func _to_string():
	return "Rule:%s:%s" % [name, get_score()]

func _debug_critera_met(c_id):
	var tested_crits = "Tested (%s) %s: "
	var temp = false
	for cid in criterion_ids:
		var cond
		if temp:
			cond = "untested"
		elif cid == c_id:
			temp = true
			cond = "failed"
		else:
			cond = "passed"
		tested_crits += "%s:%s " % [cid, cond]
	
	var isPassed = "Passed" if not temp else "Failed"
	print(tested_crits % [isPassed, str(self)])

extends Node

#var rules_DB = {}
var criteria_DB = {}
var responses_DB = {} # this might also benefit by being moved to the actor

var world : Query

func _ready():
	read_json()

func read_json():
	"""
	Reads the json array containing the list of rules, criteria, responses
	and populates the arrays. 
	Future work: different arrays for rule categories. (optimization 3,4,5)
	"""
	var file = File.new()
	file.open("res://implementation/DynamicDialogue.json", File.READ)
	var json = JSON.parse(file.get_as_text()).result
	file.close()
	
	for key in json["Criteria"]:
		var r = Criterion.new()
		r.init(key, json["Criteria"][key])
		criteria_DB[key] = r
	
	for key in json["Responses"]:
		var r = Response.new()
		r.init(key, json["Responses"][key])
		responses_DB[key] = r
#
#	for key in json["Rules"]:
#		var r = Rule.new()
#		r.init(key, json["Rules"][key])
#		rules_DB[key] = r
	
	for a in criteria_DB:  print(a)
	for a in responses_DB: print(a)
#	for a in rules_DB:     print(a)
	
#	criteria_DB = json["Criteria"]
#	response_DB = json["Responses"]
	"""
	TODO: sort the arrays 
	"""
	
	pass


#func query(agent):
#	"""
#	Function used by actors to send out a query
#	gets combined with world query and/or any other queries 
#	to decide upon a rule
#	"""
#	assert(agent.is_in_group("hasQuery"))
#	var agent_query : Query = agent.query
#
#	print("%s" % agent_query)
#
#	# For each rule, check that it's criteria are met. 
#	### This can be optimized
#	var passed_rules = []
#	for rule_id in rules_DB:
#		var rule : Rule = rules_DB[rule_id]
#		if rule.criteria_met(agent_query):
#			passed_rules.append(rule)
#
##	for p in passed_rules: print("\tpassed: %s" % p)
#
#	# get rule with highest score - This can be made redundant with sorting
#	var best_rule : Rule
#	var best_rule_score = 0
#	for rule in passed_rules:
#		if rule.get_score() > best_rule_score:
#			best_rule = rule
#			best_rule_score = rule.get_score()
#
#	# apply the best rules response
#	best_rule.initiate_response(agent)
	

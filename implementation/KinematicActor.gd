extends KinematicBody2D
class_name KinematicActor2D

"""
This class allows the actor to spawn a query and handles
the logic chain of the responses
"""

# Usage rules_DB[concept][rule_name/key]
var rules_DB = {} # database of rules for this actor

var query : Query

func _ready():
	if not is_in_group("hasQuery"):
		add_to_group("hasQuery")
	
	query = Query.new()
	query.set_fact("source", name)
	query.set_fact("concept", "NA")
	query.source = name

func init(rules_json_path):
	var file = File.new()
	file.open(rules_json_path, File.READ)
	var json = JSON.parse(file.get_as_text()).result
	file.close()
	
	for key in json["Rules"]:
		if key == "": continue
		var r = Rule.new()
		r.init(key, json["Rules"][key])
		if not r.concept in rules_DB: rules_DB[r.concept] = {} 
		rules_DB[r.concept][key] = r

func apply_query(): # this needs a better name
	"""
	Function used by actors to send out a query
	gets combined with world query and/or any other queries 
	to decide upon a rule
	"""
	assert(self.is_in_group("hasQuery"))
	var agent_query : Query = self.query
	
	print("%s" % agent_query)
	
	# For each rule, check that it's criteria are met. 
	### This can be optimized
	var passed_rules = []
	var concept = query.get_fact("concept")
	for rule_id in rules_DB[concept]:
		var rule : Rule = rules_DB[concept][rule_id]
		if rule.criteria_met(agent_query):
			passed_rules.append(rule)
	
	for p in passed_rules: print("\tpassed: %s" % p)
	
	# get rule with highest score - This can be made redundant with sorting
	var best_rule : Rule
	var best_rule_score = -1
	for rule in passed_rules:
		if rule.get_score() > best_rule_score:
			best_rule = rule
			best_rule_score = rule.get_score()
	
	print("\tbest rule: %s" % best_rule)
	
	# apply the best rules response
	if best_rule:
		initiate_response(best_rule)

func initiate_response(rule : Rule):
	var re : Response = ChatHandler.responses_DB[rule.response_id]
	yield(_respond(re), "completed") # will wait for the response to complete
	_modify_memory(rule, re) # modify the query based on rule.memories
	_resolve_rule(rule) # handlee Limit and Timed rules
	_initiate_chaining(re) # Attempt to chain response to another actor



############################ Helpers ############################



func _modify_memory(rule : Rule, re : Response):
	"""
	This method applies the memories of the rule to the query
	It also remembers that this response was said.
	"""
	var M = Memory.new()
	for mem in rule.memories:
		M.name = mem
		M.parse_memory(query)
	
	var cnt_name = "%sAmount" % re.name
	if query.has(cnt_name):
		query.set_fact(cnt_name, query.get_fact(cnt_name) + 1)
	else:
		query.set_fact(cnt_name, 1)

func _resolve_rule(rule : Rule):
	"""
	This method handles resolution of a rule. 
	Default: nothing happens
	OneShot: Rule is disabled after a single use
	Timed:   Rule is disabled for a time period
	"""
	print("\tresolving %s" % [rule])
	match rule.type:
		rule.Types.DEFAULT:
			pass
		rule.Types.LIMIT:
			rule.type_val -= 1
			if rule.type_val <= 0:
				var suc = rules_DB[rule.concept].erase(rule.name)
				assert(suc, "failed to resolve one shot rule")
			pass
		rule.Types.TIMED:
			#TODO:
			rule.disabled = true
			yield(get_tree().create_timer(rule.type_val), "timeout")
			rule.disabled = false
			pass
	pass

func _respond(re : Response):
	"""
	Applies the response
	Will wait for the response to complete if the response has a time
	 component to it
	"""
	yield(get_tree(), "idle_frame")# dunno but this needs to be here
	var first_word = re.effects.split(" ")[0]
	match first_word:
		"print":
			print()
			print(re.effects.right(6))
			print()
		"scene": # instances the scene as a child of "source"
			var sc = load(re.effects.right(6))
			self.add_child(sc)
			pass
		"speech":
			# special case for spoken dialogue
			var speech_panel = get_node_or_null("Panel")
			if not speech_panel:
				print()
				print(re.effects.right(7))
				print()
				return
			
			speech_panel.get_node("Label").text = re.effects.right(7)
			var anim = (speech_panel.get_node("AnimationPlayer") as AnimationPlayer)
			anim.play("fadeinandout")
			yield(anim, "animation_finished")

func _initiate_chaining(re : Response):
	if re.target == null:
		print("End of chain")
		return 
	
	var targets = get_tree().get_nodes_in_group("hasQuery")
#	print("possible targets: %s" % [targets])
	
	if re.target == "any":
		print("ANY")
		# choses the best match (based on number of rules)
		var best_target = null
		var best_score = null
		for t in targets:
			var t_score = (t as KinematicActor2D).rules_DB[re.new_concept].size()
			if not best_score:
				best_score = t_score
				best_target = t
				continue
			if t_score > best_score:
				best_score = t_score
				best_target = t
		
		(best_target as KinematicActor2D).query.set_fact("concept", re.new_concept)
		(best_target as KinematicActor2D).apply_query()
		#TODO: Test ANY. This code has not been validated
	
	elif re.target == "all":
		print("ALL")
		for t in targets:
			(t as KinematicActor2D).query.set_fact("concept", re.new_concept)
			(t as KinematicActor2D).apply_query()
	
	else:
		# try to find the target and ask it to initiate a response
#		print("%s -> %s" % [re.target, re.new_concept])
		
		var target_found = false
		for t in targets:
			if t.name == re.target:
				(t as KinematicActor2D).query.set_fact("concept", re.new_concept)
				(t as KinematicActor2D).apply_query()
#				ChatHandler.query(t)
				target_found = true
				break
		assert(target_found, "tried to pass on a response to a non-existant target")

















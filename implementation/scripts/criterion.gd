extends Resource
class_name Criterion

export(String) var name



func init(_key, _values):
	name = _key

#func query_passes(query : Query):
#	# returns true if the query passes this criterion
#	if not query.has(fact_id): return false
#	return _compare(query.get_fact(fact_id))

#func _compare(x):
#	if not x is String:
#		x = float(x)
#	return x >= low && high >= x

func query_passes(query : Query):
	"""
	This function figures out what to do given the various types of criterion
	key symbols: ==, >=, >, <, <=
	"""
	
	var negate = name.begins_with("Not ")
	var new_name : String = name
	if negate: new_name = new_name.right(4) # chop off the Not
#	print("negate: %s" % negate)
#	var a = int(false) ^ int(negate)
#	print("meh: %s" % a)
	
	# check if any of the key symbols are in the name
	var symbol = _get_symbol()
	# if not then apply the first method
	if not symbol:
		if not query.has(new_name): 
			print("\t\tdoesn't have %s" % new_name)
			return false
		if query.get_fact(new_name): return int(true) ^ int(negate)
		else: return int(false) ^ int(negate) # bitwise XOR
	
	
	# else apply the second method and parse which symbol
	var key = new_name.split(symbol)[0]
	var value = new_name.split(symbol)[1]
	if not query.has(key): 
		print("query doesn't have the fact")
		return false
	# wrap key/value in quotes if they are strings
	key = query.get_fact(key)
	
	var expr = _combine_expr(key, value, symbol)
	
	return int(_safe_eval(expr)) ^ int(negate)


func _safe_eval(expr):
	#	print("\tAttempting to parse expression %s" % expr)
	var expression = Expression.new()
	var error = expression.parse(expr, [])
	if error != OK:
		print(expression.get_error_text())
		return false
	var result = expression.execute([], null, true)
	if not expression.has_execute_failed():
#		print("\tExpression evaluation success with result %s" % result)
		return result
	print("\t\tFailed to evaluate expression")
	return false

func _combine_expr(key, value, symbol):
	var expr = ""
	
	if key is String: expr += "'%s'"
	else:             expr += "%s"
	expr += "%s"
	float()
	if value.is_valid_float(): expr += "%s"
	else:                      expr += "'%s'"
	
	return expr % [key, symbol, value]

func _get_symbol():
	"""
	returns one of the five symbols or null if none was found
	"""
	for s in ["==", "<=", ">=", "<", ">"]:
#		print("\t\t\t\t%s  %s" % [name, s])
		if (name as String).count(s) >= 1:
			return s
	return null

########### DEBUG ##########

func _to_string():
	return "Criterion:%s" % [name]

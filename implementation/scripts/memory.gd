extends Resource
class_name Memory

export(String) var name

func parse_memory(query : Query):
	"""
	This method applies the memory to the query
	
	Memory syntax is:
		[String]+[Value]
	"""
	if "+" in name:
		var a = name.split("+")
		if query.has(a[0]):
			query.set_fact(a[0], query.get_fact(a[0]) + float(a[1]))
		else:
			query.set_fact(a[0], float(a[1]))
			

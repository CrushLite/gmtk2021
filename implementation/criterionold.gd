extends Resource
class_name CriterionOLD

export(String) var name
export(String) var fact_id
export(float) var low
export(float) var high

"""
 "IsPlayer": {
	  "Key": "source",
	  "Low": "player",
	  "High": "player"
	},
"""

"""
TODO: add nondefined criterions - criterion function determined by the text
[String] -> same as if ([String]): return true. Supports Not
	ex: IsMoving, SeenBarrel, NotIsMoving 
[String]=[String] -> is an equality operation
	ex: BarrelsSeen=1, EnemiesKilled=100
	other symbols >, <, ??? is this a good idea?
	
"""

func init(_key, _values):
	name = _key
	fact_id = _values["Key"]
	low = _values["Low"]
	high = _values["High"]

func query_passes(query : Query):
	# returns true if the query passes this criterion
	if not query.has(fact_id): return false
	return _compare(query.get_fact(fact_id))

func _compare(x):
	if not x is String:
		x = float(x)
	return x >= low && high >= x

########### DEBUG ##########

func _to_string():
	return "Criterion:%s" % [name]

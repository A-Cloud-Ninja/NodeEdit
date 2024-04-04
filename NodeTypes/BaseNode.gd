extends GraphNode
@onready var argmap = {
	"string" = (func(c): 
				if c is TextEdit or c is Label:
					return c.text
				elif c.get_child_count() > 0:
					for child in c.get_children():
						if child is TextEdit or child is Label:
							return child.text),
	"number" = (func(c):
				var t = argmap.string.call(c)
				return float(t)
				)
}

@onready var namemap = [
	"exec",
	"string",
	"number"
]

func _ready():
	#print("Basenode Ready")
	_get_output_arguments()


func _get_output_arguments():
	var args = []
	for i in get_output_port_count():
		var t = get_output_port_type(i)
		var t_name = namemap[t]
		if argmap.has(t_name):
			var f = argmap[t_name]
			var res = f.call(get_child(i))
			args.append(res)
	return args

extends Control
@onready var OptionSelect = $OptionButton
@onready var ge = $GraphEdit
@onready var init = $GraphEdit/GraphNode
# Connection Types
# 0 : Exec Pins, should only be used for walking the exec path from init
# 1 : String Pins, pulls string from the internals of the objects
# 2 : Arbitrary number Pins, no guarantees on float/int
# 10: Debug Printout: can take numbers or strings
#
@onready var nodemap = {
	#"Basic" = preload("res://NodeTypes/BaseNode.tscn"),
	"Print" = preload("res://NodeTypes/PrintNode.tscn"),
	"String" = preload("res://NodeTypes/StringElement.tscn"),
	"Number" = preload("res://NodeTypes/NumberElement.tscn"),
	"Add" = preload("res://NodeTypes/AddNode.tscn"),
	"Concat" = preload("res://NodeTypes/ConcatNode.tscn")
}

@onready var valid = [
	#0 EXEC
	[0,0],
	#1 STRING
	[1,1],
	[1,10],
	#2 NUMBER
	[2,2],
	[2,10]
	#10 PRINT DEBUG (number+string)
]

func _ready():
	for i in nodemap:
		OptionSelect.add_item(i)
	for t in valid:
		ge.add_valid_connection_type(t[0],t[1])

func _process(delta):
	pass


func NewNode(index):
	var id = OptionSelect.get_item_id(index)
	var md = OptionSelect.get_item_text(id)
	ge.add_child(nodemap[md].instantiate())

func get_graph_child(_name):
	for child in ge.get_children():
		if child.name == _name:
			return child


func _on_graph_edit_connection_request(from_node, from_port, to_node, to_port):
	var n1 = get_graph_child(from_node)
	var n2 = get_graph_child(to_node)
	var t1 = n1.get_output_port_type(from_port)
	var t2 = n2.get_input_port_type(to_port)
	if ge.is_valid_connection_type(t1,t2):
		ge.connect_node(from_node,from_port,to_node,to_port)

func get_input_arguments_for(node):
	var count = node.get_input_port_count()
	var args = []
	for i in count:
		if not node.get_input_port_type(i) == 0:
			var _n = get_connected_node_from(node,i,true)
			var __args = _n[0]._get_output_arguments()
			var idx = _n[1]
			if __args.size() > idx:
				args.append(__args[idx])
			elif __args.size() == idx:
				args.append(__args[idx-1])
	return args

func _get_input(node,pin):
	for connection in ge.get_connection_list():
		if connection.to_node == node.name and connection.to_port == pin:
			return [get_graph_child(connection.from_node),connection.from_port]
func _get_output(node,pin):
	for connection in ge.get_connection_list():
		if connection.from_node == node.name and connection.from_port == pin:
			return [get_graph_child(connection.to_node),connection.to_port]
func get_connected_node_from(node,pin,input):
	var n = false
	if input:
		n = _get_input(node,pin)
	else:
		n = _get_output(node,pin)
	if n:
		return n


func get_next(node):
	var count = node.get_output_port_count()
	for i in count:
		if node.get_output_port_type(i) == 0:
			var next = get_connected_node_from(node,i,false)
			if next:
				return next
		

@onready var current = init
func _on_timer_timeout():
	if current:
		var n = get_next(current)
		if n:
			var args_to_pass = get_input_arguments_for(n[0])
			n[0].exec(args_to_pass)
			current = n[0]
		else:
			current = init

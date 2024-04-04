extends "res://NodeTypes/BaseNode.gd"
@onready var value = ""
func _ready():
	pass
	#print("Print node ready")

func _get_output_arguments():
	return [value]

func exec(argsv):
	if argsv.size() >= 2:
		value = argsv[0]+argsv[1]

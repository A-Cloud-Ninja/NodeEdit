extends GraphNode
@onready var t = $TextEdit

func _get_output_arguments():
	if GraphVars.has(t.text) and GraphVars[t.text].size() > 0:
		return GraphVars[t.text][0]

func _process(delta):
	pass


func _on_text_edit_text_set():
	if not GraphVars.has(t.text):
		GraphVars[t.text] = ["DefaultValue"]

extends LineEdit
class_name SearchBar

@onready var item_list: ItemList = %ItemList
var matches: Array[MediaEntry] = []

func _on_text_changed(new_text: String) -> void:
	var media_list: Array = get_tree().get_nodes_in_group("media_object")
	matches = []
	if item_list.item_count > 0:
		item_list.show()
	else:
		item_list.hide()
	item_list.clear()
	if new_text == "":
		return
	for entry: MediaEntry in media_list:
		if new_text.to_lower() in entry.name.to_lower():
			if !matches.has(entry):
				matches.append(entry)
	for child: MediaEntry in matches:
		item_list.add_item(child.name)
	#print(matches)

func _on_item_list_item_selected(index: int) -> void:
	for entry: MediaEntry in matches:
		if entry.name == item_list.get_item_text(index):
			Global.selectObject.emit(entry)
	item_list.hide()

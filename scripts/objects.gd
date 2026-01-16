extends Node3D
class_name Objects

const MEDIA_ENTRY: PackedScene = preload("uid://chor557ybioq7")

## Retrieve Bingo List
const url_media_list: String = "https://opensheet.elk.sh/1plO1jEjqXTol8iK2kOGjlOU5ONFEsfw5LwWfMgwjyvA/MediaList"
const headers: Array = ["Content-Type: application/x-www-form-urlencoded"]

var media_list: Array[Dictionary] = []

func _ready() -> void:
	get_media_list()

## Retrieve Bingo Word List from Google Spreadsheets
func get_media_list() -> void:
	var http: HTTPRequest = HTTPRequest.new()
	var pool_headers = PackedStringArray(headers)
	add_child(http)
	http.request(url_media_list, pool_headers, HTTPClient.METHOD_GET)
	http.request_completed.connect(_on_request_completed)

func _on_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var database: String = body.get_string_from_utf8()
	var json: JSON = JSON.new()
	var data: String = JSON.stringify(database)
	var error = json.parse(data)
	if error == OK:
		var data_received = json.data
		if typeof(data_received) == TYPE_STRING: # array
			var data_array: Array = str_to_var(data_received)
			for entry: Dictionary in data_array:
				media_list.append(entry)
		else:
			print("Unexpected data")
	else:
		print("JSON Parse Error: %s in %s at line %d" % [json.get_error_message(), data, json.get_error_line()])
	
	for i: int in media_list.size():
		var media_item = MEDIA_ENTRY.instantiate()
		add_child(media_item)
		media_item.add_media_entry(media_list[i])

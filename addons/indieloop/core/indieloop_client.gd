class_name IndieLoopClient
extends RefCounted
## The main entry point and public API for the IndieLoop SDK.
##
## This class acts as the central hub (Facade) for the entire IndieLoop system. It is designed
## to be used as an AutoLoad singleton in your Godot project, providing a simple and unified
## interface for all SDK functionalities. Although it is intended to be used as a singleton,
## it can also be instantiated directly if needed. [br]
##
## It manages the internal components responsible for: [br]
##  - Capturing and sending bug reports. [br]
##  - Gathering console logs and performance metrics (FPS, RAM, CPU etc.). [br]
##  - Tracking custom gameplay events for analytics. [br]
##  - Handling all communication with the IndieLoop backend. [br]

var sdk_version: String = "0.1.0"
var sdk_api_url: String = "https://api.getindieloop.io/v1"

var config: IndieLoopConfig
var system_info: IndieLoopSystemInfo = IndieLoopSystemInfo.new()
var performance_metrics: IndieLoopPerformanceMetrics = IndieLoopPerformanceMetrics.new()

# The dedicated request queue handler.
var _http: IndieLoopHTTP

func _init(config: IndieLoopConfig):
	self.config = config

	# Create an instance of HTTP client for handling requests.
	_http = IndieLoopHTTP.new()
	Engine.get_main_loop().root.add_child(_http)

## Sends a request to the IndieLoop API and returns a future for the response.
func send_request(endpoint: String, method: HTTPClient.Method = HTTPClient.Method.METHOD_GET, body: Dictionary = {}, headers: Dictionary = {}):
	var url := sdk_api_url + endpoint

	var headers_array: PackedStringArray = []
	for key in headers:
		headers_array.append("%s: %s" % [key, headers[key]])

	var request_body := ""
	if not body.is_empty():
		# This component expects standard headers.
		headers_array.append("Content-Type: application/json")
		request_body = JSON.stringify(body)

	return _http.send_request(url, method, headers_array, request_body)

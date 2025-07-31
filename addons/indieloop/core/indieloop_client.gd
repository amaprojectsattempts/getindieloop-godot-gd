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
var sdk_user_agent: String = "IndieLoop-Godot-SDK/%s" % sdk_version

var config: IndieLoopConfig
var system_info: IndieLoopSystemInfo = IndieLoopSystemInfo.new()
var performance_metrics: IndieLoopPerformanceMetrics = IndieLoopPerformanceMetrics.new()
var breadcrumbs: IndieLoopBreadcrumbs = IndieLoopBreadcrumbs.new()

# The dedicated request queue handler.
var _http: IndieLoopHTTP

func _init(config: IndieLoopConfig):
	self.config = config
	self._http = config.http_client

## Sends a request to the IndieLoop API and returns a future for the response.
func send_request(endpoint: String, method: HTTPClient.Method = HTTPClient.Method.METHOD_GET, body: Dictionary = {}, headers: Dictionary = {}):
	# --- Pre-flight Checks ---
	if not is_instance_valid(self._http):
		return self._http.fail_request(
			"IndieLoopClient Error: HTTP client is not initialized. Cannot send request.",
			HTTPRequest.RESULT_CANT_CONNECT
		)

	if self.config.project_token.is_empty():
		# This is a configuration error, so REQUEST_FAILED is more appropriate.
		return self._http.fail_request(
			"IndieLoopClient Error: Project Token is not configured. Cannot send request.",
			HTTPRequest.RESULT_REQUEST_FAILED
		)

	# --- Request Preparation ---
	var url := self.sdk_api_url + endpoint

	var final_headers: Dictionary = {
		"User-Agent": self.sdk_user_agent,
		"Accept": "application/json",
		"X-Request-ID": "%s-%s" % [Time.get_ticks_usec(), randi()]
	}

	# Add the project token (guaranteed to exist by the check above).
	final_headers["X-Project-Token"] = self.config.project_token

	# Merge any user-provided headers, allowing them to override defaults.
	final_headers.merge(headers)

	var request_body := ""
	if not body.is_empty():
		# Add content-type header only if there is a body.
		final_headers["Content-Type"] = "application/json"
		request_body = JSON.stringify(body)

	# Convert the final dictionary to the PackedStringArray format required by the HTTP client.
	var headers_array: PackedStringArray = []
	for key in final_headers:
		headers_array.append("%s: %s" % [key, final_headers[key]])

	# Delegate the request to the queue.
	return self._http.send_request(url, method, headers_array, request_body)

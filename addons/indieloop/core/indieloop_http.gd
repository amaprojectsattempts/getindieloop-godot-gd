class_name IndieLoopHTTP
extends Node

## Manages a sequential queue of HTTP requests, returning a future for each one.
## This node must be added to the scene tree to function correctly.

#region DataClasses

## Encapsulates the complete result of a completed HTTP request.
class ResponseResult extends RefCounted:
	## The low-level result code from the HTTPRequest node.
	var result_code: int
	var response_code: int
	var body_raw: PackedByteArray
	var body_string: String
	var body_json: Variant
	var error: String
	var duration_ms: int

	var _headers: PackedStringArray
	var _headers_dict: Dictionary = {}
	var _headers_parsed: bool = false

	func _init(p_result_code: int, p_response_code: int, p_headers: PackedStringArray, p_body: PackedByteArray, p_error: String = "", p_duration_ms: int = 0):
		self.result_code = p_result_code
		self.response_code = p_response_code
		self._headers = p_headers
		self.body_raw = p_body
		self.body_string = p_body.get_string_from_utf8()
		self.error = p_error
		self.duration_ms = p_duration_ms

		var json_parser := JSON.new()
		if json_parser.parse(body_string) == OK:
			self.body_json = json_parser.get_data()
		else:
			self.body_json = null

	## Returns true if the request was successful (HTTP 2xx status code).
	func is_success() -> bool:
		return response_code >= 200 and response_code < 300

	## Returns true if a client-side error occurred (e.g., connection failed).
	func has_error() -> bool:
		return not error.is_empty() or result_code != HTTPRequest.RESULT_SUCCESS

	## Returns true if the server responded with a client error code (4xx).
	func is_client_error() -> bool:
		return response_code >= 400 and response_code < 500

	## Returns true if the server responded with a server error code (5xx).
	func is_server_error() -> bool:
		return response_code >= 500 and response_code < 600

	## Parses and returns the response headers as a case-insensitive dictionary.
	func get_headers_as_dictionary() -> Dictionary:
		if _headers_parsed:
			return _headers_dict

		for header_line in _headers:
			var parts = header_line.split(": ", false, 1)
			if parts.size() == 2:
				_headers_dict[parts[0].to_lower()] = parts[1]

		_headers_parsed = true
		return _headers_dict

	## Returns a single header value by its name (case-insensitive).
	func get_header(header_name: String) -> String:
		if not _headers_parsed:
			get_headers_as_dictionary() # Ensure headers are parsed.
		return _headers_dict.get(header_name.to_lower(), "")

	## Attempts to create an ImageTexture from the response body.
	## Returns null if the body is not a valid PNG or JPEG.
	func get_body_as_texture() -> ImageTexture:
		if body_raw.is_empty():
			return null

		var image := Image.new()
		var err: Error

		var content_type := get_header("content-type").to_lower()

		if "png" in content_type:
			err = image.load_png_from_buffer(body_raw)
		elif "jpeg" in content_type or "jpg" in content_type:
			err = image.load_jpg_from_buffer(body_raw)
		else:
			# Fallback: try to load as common image types if Content-Type is missing/wrong.
			err = image.load_png_from_buffer(body_raw)

			if err != OK:
				err = image.load_jpg_from_buffer(body_raw)

		if err != OK:
			printerr("Failed to load image from response body. Error: ", error_string(err))
			return null

		return ImageTexture.create_from_image(image)

	func to_dict() -> Dictionary:
		return {
			"result_code": result_code,
			"response_code": response_code,
			"body_raw": body_raw,
			"body_string": body_string,
			"body_json": body_json,
			"error": error,
			"duration_ms": duration_ms,
			"headers": get_headers_as_dictionary()
		}
	
	func _to_string() -> String:
		return str(self.to_dict())

## A future that represents the result of a request that will complete later.
class RequestFuture extends RefCounted:
	signal completed(result: ResponseResult)

	var _unique_id: int = randi()
	var _is_complete: bool = false

	func _fulfill(result: ResponseResult):
		if _is_complete:
			return

		_is_complete = true

		completed.emit(result)

	func is_complete() -> bool:
		return _is_complete

	func to_dict() -> Dictionary:
		return {
			"unique_id": _unique_id,
			"is_complete": _is_complete
		}
	
	func _to_string() -> String:
		return str(self.to_dict())

#endregion


#region Implementation

var _http_client: HTTPRequest
var _request_queue: Array[Dictionary] = []
var _is_processing: bool = false


func _enter_tree():
	_http_client = HTTPRequest.new()
	add_child(_http_client)
	_http_client.request_completed.connect(_on_request_completed)


## Creates and returns a future that is immediately fulfilled with an error.
func fail_request(error_msg: String, result_code: int = HTTPRequest.RESULT_CONNECTION_ERROR, future: RequestFuture = null) -> RequestFuture:
	printerr(error_msg)
	
	if not is_instance_valid(future):
		future = RequestFuture.new()
	
	var error_result := ResponseResult.new(result_code, -1, [], PackedByteArray(), error_msg, 0)
	future.call_deferred("_fulfill", error_result)

	return future

## Queues a new HTTP request and returns a future to await the result.
func send_request(url: String, method: int = HTTPClient.METHOD_GET, headers: PackedStringArray = [], body: String = "") -> RequestFuture:
	var future := RequestFuture.new()

	var request_data: Dictionary = {
		"future": future,
		"url": url,
		"method": method,
		"headers": headers,
		"body": body
	}

	_request_queue.append(request_data)
	_process_queue()

	return future


## Processes the next item in the queue if the client is not busy.
func _process_queue():
	if _is_processing or _request_queue.is_empty():
		return

	_is_processing = true
	var request_data: Dictionary = _request_queue.pop_front()

	# Store metadata on the client to retrieve it when the request completes.
	_http_client.set_meta("current_future", request_data.future)
	_http_client.set_meta("start_time_ms", Time.get_ticks_msec())

	var error := _http_client.request(
		request_data.url,
		request_data.headers,
		request_data.method,
		request_data.body
	)

	if error != OK:
		var err_msg := "HTTPRequestQueue failed to start request to %s: %s" % [request_data.url, error_string(error)]
		var future: RequestFuture = _http_client.get_meta("current_future")
		
		fail_request(err_msg, error, future)

		_http_client.remove_meta("current_future")
		_http_client.remove_meta("start_time_ms")
		_is_processing = false
		_process_queue()


## Signal handler for when the HTTPRequest node completes its task.
func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var future: RequestFuture = _http_client.get_meta("current_future")
	var start_time_ms: int = _http_client.get_meta("start_time_ms", 0)
	var duration_ms: int = Time.get_ticks_msec() - start_time_ms

	var response_result := ResponseResult.new(result, response_code, headers, body, "", duration_ms)

	if is_instance_valid(future):
		future._fulfill(response_result)

	# Clean up metadata and flag that we're ready for the next request.
	_http_client.remove_meta("current_future")
	_http_client.remove_meta("start_time_ms")
	_is_processing = false

	_process_queue()

#endregion
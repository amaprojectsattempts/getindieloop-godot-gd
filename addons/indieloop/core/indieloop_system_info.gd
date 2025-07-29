class_name IndieLoopSystemInfo
extends RefCounted

## This class represents the RAM information in various units.
class Ram:
	var bytes: int
	var kilobytes: float
	var megabytes: float
	var gigabytes: float

	func _to_string() -> String:
		return str(Dictionary({
			"bytes": bytes,
			"kilobytes": kilobytes,
			"megabytes": megabytes,
			"gigabytes": gigabytes
		}))

## This class represents the system information collected by the IndieLoop SDK.
class SystemInfo:
	var os: String
	var cpu: String
	var gpu: String
	var gpu_driver: String
	var ram: Ram
	var game_resolution: String
	var screen_resolution: String

	func _to_string() -> String:
		return str(Dictionary({
			"os": os,
			"cpu": cpu,
			"gpu": gpu,
			"gpu_driver": gpu_driver,
			"ram": ram,
			"game_resolution": game_resolution,
			"screen_resolution": screen_resolution
		}))

var overrided_screen_id: int = -1
var overrided_window_id: int = -1


## Gathers a comprehensive dictionary of system information.
func get_info() -> SystemInfo:
	var info = SystemInfo.new()
	info.os = get_os()
	info.cpu = get_cpu()
	info.gpu = get_gpu()
	info.gpu_driver = get_gpu_driver()
	info.ram = get_ram()
	info.game_resolution = get_game_resolution()
	info.screen_resolution = get_screen_resolution()

	return info

## Returns the operating system name and version.[br]
func get_os() -> String:
	return OS.get_name() + " " + OS.get_version()

## Returns the CPU/processor name.
func get_cpu() -> String:
	return OS.get_processor_name()

## Returns the GPU name.
func get_gpu() -> String:
	if RenderingServer.get_video_adapter_name() != "":
		return RenderingServer.get_video_adapter_vendor() + " - " + RenderingServer.get_video_adapter_name()

	return "N/A"

## Returns the GPU driver information.
func get_gpu_driver() -> String:
	# This function is not available on all platforms (e.g., Web), so we check for it.
	if OS.has_method("get_video_adapter_driver_info"):
		return " ".join(OS.get_video_adapter_driver_info())

	return "N/A"

## Returns a dictionary with physical RAM in various units.
func get_ram() -> Ram:
	var bytes: int = OS.get_memory_info()["physical"]
	var kb: float = bytes / 1024.0
	var mb: float = kb / 1024.0
	var gb: float = mb / 1024.0

	var ram = Ram.new()
	ram.bytes = bytes
	ram.kilobytes = kb
	ram.megabytes = mb
	ram.gigabytes = gb

	return ram

## Returns the screen resolution as a formatted string.
func get_game_resolution() -> String:
	var window_id = get_window_id()
	var size = DisplayServer.window_get_size(window_id)
	return "%sx%s" % [size.x, size.y]

## Returns the screen resolution as a formatted string.
func get_screen_resolution() -> String:
	var screen_id = get_screen_id()
	var size = DisplayServer.screen_get_size(screen_id)
	return "%sx%s" % [size.x, size.y]

## Gets the screen ID to be used for measurements.
##
## You can override the returned screen ID by using set_screen_id().
## If you set it to -1, it will fetch the current screen ID from DisplayServer.
func get_screen_id() -> int:
	if overrided_screen_id != -1:
		return overrided_screen_id

	# Default to screen 0 if headless or no current screen can be found.
	if DisplayServer.get_name() != "headless":
		var current_screen = DisplayServer.window_get_current_screen()

		if current_screen != -1:
			return current_screen

	return 0

## Manually sets the screen ID to use for resolution checks.
## Set to -1 to use the current screen ID from DisplayServer.
func set_screen_id(id: int = -1) -> void:
	overrided_screen_id = id

func get_window_id() -> int:
	# If a window ID is overridden, return it.
	if overrided_window_id != -1:
		return overrided_window_id

	return 0

## Manually sets the window ID to use for resolution checks.
## Set to -1 to use the default window ID (0).
func set_window_id(id: int = -1) -> void:
	overrided_window_id = id

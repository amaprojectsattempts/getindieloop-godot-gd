class_name IndieLoopSystemInfo
extends RefCounted

#region DataClasses

class Ram:
	var bytes: int
	var kilobytes: float
	var megabytes: float
	var gigabytes: float

	func to_dict() -> Dictionary:
		return {
			"bytes": bytes,
			"kilobytes": kilobytes,
			"megabytes": megabytes,
			"gigabytes": gigabytes
		}

	func _to_string() -> String:
		return str(self.to_dict())

class SystemInfo:
	var os: String
	var cpu_name: String
	var cpu_cores: int
	var gpu_name: String
	var gpu_driver: String
	var ram: Ram
	var game_resolution: String
	var screen_resolution: String
	var screen_refresh_rate: float
	var screen_scale: float
	var engine_version: String
	var language: String
	var unique_device_id: String
	var device_model: String
	
	func to_dict() -> Dictionary:
		return {
			"os": os,
			"cpu_name": cpu_name,
			"cpu_cores": cpu_cores,
			"gpu_name": gpu_name,
			"gpu_driver": gpu_driver,
			"ram": ram.to_dict(),
			"game_resolution": game_resolution,
			"screen_resolution": screen_resolution,
			"screen_refresh_rate": screen_refresh_rate,
			"screen_scale": screen_scale,
			"engine_version": engine_version,
			"language": language,
			"unique_device_id": unique_device_id,
			"device_model": device_model
		}

	func _to_string() -> String:
		return str(self.to_dict())

#endregion

#region Implementation

var overrided_screen_id: int = -1
var overrided_window_id: int = -1


## Gathers a comprehensive dictionary of system information.
func get_info() -> SystemInfo:
	var info = SystemInfo.new()
	info.os = get_os()
	info.cpu_name = get_cpu_name()
	info.cpu_cores = get_cpu_cores()
	info.gpu_name = get_gpu_name()
	info.gpu_driver = get_gpu_driver()
	info.ram = get_ram()
	info.game_resolution = get_game_resolution()
	info.screen_resolution = get_screen_resolution()
	info.screen_refresh_rate = get_screen_refresh_rate()
	info.screen_scale = get_screen_scale()
	info.engine_version = get_engine_version()
	info.language = get_language()
	info.unique_device_id = get_unique_device_id()
	info.device_model = get_device_model()

	return info

## Returns the operating system name and version.
func get_os() -> String:
	return " ".join([OS.get_name(), OS.get_version()])

## Returns the CPU/processor name.
func get_cpu_name() -> String:
	return OS.get_processor_name()

## Returns the number of CPU cores.
func get_cpu_cores() -> int:
	return OS.get_processor_count()

## Returns the GPU name.
func get_gpu_name() -> String:
	return " ".join([RenderingServer.get_video_adapter_vendor(), RenderingServer.get_video_adapter_name()])

## Returns the GPU driver information.
func get_gpu_driver() -> String:
	# This function is not available on all platforms (e.g., Web), so we check for it.
	return " ".join(OS.get_video_adapter_driver_info())

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

## Returns the screen's refresh rate.
func get_screen_refresh_rate() -> float:
	var screen_id = get_screen_id()
	var refresh_rate = DisplayServer.screen_get_refresh_rate(screen_id)

	# If the refresh rate is not available (eg. on web), default to 60.0 Hz.
	if refresh_rate <= 0:
		refresh_rate = 60.0

	return refresh_rate

## Returns the screen's scale factor.
func get_screen_scale() -> float:
	var screen_id = get_screen_id()
	return DisplayServer.screen_get_scale(screen_id)

## Returns the Godot version.
func get_engine_version() -> String:
	var version = Engine.get_version_info()
	return "Godot %s" % [version.string]

## Returns the system's language.
func get_language() -> String:
	return OS.get_locale_language()

## Returns a unique identifier for the device.
func get_unique_device_id() -> String:
	return OS.get_unique_id()

## Returns the device model.
func get_device_model() -> String:
	return OS.get_model_name()

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

#endregion
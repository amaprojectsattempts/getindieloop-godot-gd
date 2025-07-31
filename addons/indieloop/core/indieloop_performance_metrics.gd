class_name IndieLoopPerformanceMetrics
extends RefCounted

## This class holds a snapshot of performance metrics at a specific moment.
class PerformanceSnapshot:
	var snapshot_time_ms: float = Time.get_ticks_msec() # Timestamp in seconds
	var fps: int
	var ram_usage_mb: int
	var vram_usage_mb: int

	# Placeholders, as these cannot be retrieved with standard GDScript
	# a GDExtension is required to get this information.
	var cpu_usage_percentage: float = 0.0
	var gpu_usage_percentage: float = 0.0


	func _to_string() -> String:
		return str(Dictionary({
			"snapshot_time_ms": snapshot_time_ms,
			"fps": fps,
			"ram_usage_mb": ram_usage_mb,
			"cpu_usage_percentage": cpu_usage_percentage,
			"gpu_usage_percentage": gpu_usage_percentage,
			"vram_usage_mb": vram_usage_mb
		}))


## Gathers a snapshot of the current performance metrics.
func get_snapshot() -> PerformanceSnapshot:
	var snapshot = PerformanceSnapshot.new()

	# This works in both debug and release builds.
	snapshot.fps = Performance.get_monitor(Performance.TIME_FPS)
	
	# These metrics are debug-only. In a release build, they will return 0.
	# For production use, a GDExtension is required to get this information.
	snapshot.ram_usage_mb = get_process_ram_usage()
	snapshot.vram_usage_mb = get_vram_usage()
	
	return snapshot

## Returns the current process RAM usage in megabytes.
## NOTE: This function only works in debug builds. In a release build, it will return 0.
## Godot's standard API does not provide a way to get this information in release builds.
func get_process_ram_usage() -> int:
	var ram_bytes = Performance.get_monitor(Performance.MEMORY_STATIC)
	return int(ram_bytes / (1024.0 * 1024.0))

## Returns the video RAM (VRAM) usage in megabytes.
## NOTE: This function only works in debug builds. In a release build, it will return 0.
## Godot's standard API does not provide a way to get this information in release builds.
func get_vram_usage() -> int:
	var vram_bytes = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	return int(vram_bytes / (1024.0 * 1024.0))
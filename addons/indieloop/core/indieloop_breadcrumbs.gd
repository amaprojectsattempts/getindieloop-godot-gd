class_name IndieLoopBreadcrumbs
extends RefCounted

#region DataClasses

class Breadcrumb:
	var timestamp: int = Time.get_unix_time_from_system()
	var category: String
	var message: String
	var metadata: Array[Metadata]

	func to_dict() -> Dictionary:
		return {
			"timestamp": timestamp,
			"category": category,
			"message": message,
			"metadata": metadata
		}
	
	func _to_string() -> String:
		return str(self.to_dict())

class Metadata:
	var key: String
	var value: Variant

	func to_dict() -> Dictionary:
		return {
			"key": key,
			"value": value
		}
		
	func _to_string() -> String:
		return str(self.to_dict())

#endregion


#region Implementation

const MAX_BREADCRUMBS = 100
const MAX_METADATA_ENTRIES = 10

var _breadcrumbs: Array[Breadcrumb] = []

# Adds a new breadcrumb. The oldest is removed if the collection exceeds MAX_BREADCRUMBS.
func add(category: String, message: String, metadata: Array[Metadata] = []) -> Breadcrumb:
	# Get rid of the oldest breadcrumb if we exceed the maximum limit.
	if _breadcrumbs.size() >= MAX_BREADCRUMBS:
		_breadcrumbs.pop_front()

	# Enforce the metadata limit.
	if metadata.size() > MAX_METADATA_ENTRIES:
		metadata = metadata.slice(0, MAX_METADATA_ENTRIES)

	# Create and add the new breadcrumb.
	var breadcrumb = Breadcrumb.new()
	breadcrumb.category = category
	breadcrumb.message = message
	breadcrumb.metadata = metadata

	_breadcrumbs.append(breadcrumb)

	return breadcrumb

## Clears all breadcrumbs.
func clear() -> void:
	_breadcrumbs.clear()

## Returns a copy of the current breadcrumbs.
func get_breadcrumbs() -> Array[Breadcrumb]:
	return _breadcrumbs.duplicate()

#endregion
class_name IndieLoopBreadcrumbs
extends RefCounted

#region DataClasses

class Breadcrumb:
	var timestamp: int = Time.get_unix_time_from_system()
	var category: String = ""
	var message: String = ""
	var metadata: Array[IndieLoopMetadata] = []

	func to_dict() -> Dictionary:
		var metadata_dicts: Array[Dictionary] = []
		for item in metadata:
			metadata_dicts.append(item.to_dict())

		return {
			"timestamp": timestamp,
			"category": category,
			"message": message,
			"metadata": metadata_dicts
		}
	
	func _to_string() -> String:
		return str(self.to_dict())

#endregion


#region Implementation

const MAX_BREADCRUMBS = 100
const MAX_METADATA_ENTRIES = 10

var _breadcrumbs: Array[Breadcrumb] = []

# Adds a new breadcrumb. The oldest is removed if the collection exceeds MAX_BREADCRUMBS.
func add(category: String, message: String, metadata: Array[IndieLoopMetadata] = []) -> Breadcrumb:
	# Get rid of the oldest breadcrumb if we exceed the maximum limit.
	if _breadcrumbs.size() >= MAX_BREADCRUMBS:
		_breadcrumbs.pop_front()

	# Stripe to latest metadata entries if the size exceeds MAX_METADATA_ENTRIES.
	if metadata.size() > MAX_METADATA_ENTRIES:
		metadata = metadata.slice(metadata.size() - MAX_METADATA_ENTRIES, metadata.size())
		push_warning("Metadata size exceeds, trimming to latest %d entries." % [MAX_METADATA_ENTRIES])

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
func get_all() -> Array[Breadcrumb]:
	return _breadcrumbs.duplicate()

#endregion
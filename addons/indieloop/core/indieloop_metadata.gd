class_name IndieLoopMetadata
extends RefCounted

## A class to store a piece of metadata, including its name, value, and type.

## Defines the supported data types for metadata.
enum Type {
	TEXT, # String
	JSON, # String that can be parsed as JSON
	VECTOR2, # Vector2 instance
	VECTOR3, # Vector3 instance
	QUATERNION, # Quaternion instance
	COLOR, # Color instance
	BOOLEAN, # bool
	INTEGER, # int
	FLOAT, # float
	NULL, # A null value
	OTHER # A failover type for unsupported or unrecognized types
}

var name: String
var value: Variant
var type: Type = Type.TEXT

## The constructor now casts to a string as a final fallback.
func _init(p_name: String, p_value: Variant):
	self.name = p_name

	# Handle null values as a valid type
	if p_value == null:
		self.type = Type.NULL
		self.value = null
		return

	var value_type = typeof(p_value)

	match value_type:
		TYPE_STRING:
			var json_parser := JSON.new()
			var error = json_parser.parse(p_value)
			if error == OK:
				self.type = Type.JSON
			else:
				self.type = Type.TEXT
			self.value = p_value
		TYPE_VECTOR2:
			self.type = Type.VECTOR2
			self.value = p_value
		TYPE_VECTOR3:
			self.type = Type.VECTOR3
			self.value = p_value
		TYPE_QUATERNION:
			self.type = Type.QUATERNION
			self.value = p_value
		TYPE_COLOR:
			self.type = Type.COLOR
			self.value = p_value
		TYPE_BOOL:
			self.type = Type.BOOLEAN
			self.value = p_value
		TYPE_INT:
			self.type = Type.INTEGER
			self.value = p_value
		TYPE_FLOAT:
			self.type = Type.FLOAT
			self.value = p_value
		_:
			# Fallback 1: Try to serialize the value to a JSON string
			var json_string := JSON.stringify(p_value)

			# If the value is not empty and can be serialized to JSON, use JSON type
			if not json_string.is_empty():
				self.type = Type.JSON
				self.value = json_string
			else:
				# Fallback 2: Cast the value to a string and mark as OTHER
				self.type = Type.OTHER
				self.value = str(p_value)

				# Warn the user that a fallback conversion occurred
				var received_type_str := type_string(value_type)
				var warning_msg := "Value for '%s' (type: %s) could not be serialized to JSON. It has been converted to a string as a fallback (TYPE_OTHER)."
				push_warning(warning_msg % [name, received_type_str])


## Converts the metadata object to a dictionary for proper serialization.
func to_dict() -> Dictionary:
	var serializable_value = value

	match type:
		Type.VECTOR2:
			serializable_value = {"x": value.x, "y": value.y}
		Type.VECTOR3:
			serializable_value = {"x": value.x, "y": value.y, "z": value.z}
		Type.QUATERNION:
			serializable_value = {"x": value.x, "y": value.y, "z": value.z, "w": value.w}
		Type.COLOR:
			serializable_value = {"r": value.r, "g": value.g, "b": value.b, "a": value.a}
		_:
			pass

	return {
		"name": name,
		"type": Type.find_key(type).to_lower(),
		"value": serializable_value
	}

func _to_string() -> String:
	return str(self.to_dict())

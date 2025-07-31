class_name IndieLoopMetadata
extends RefCounted

## A class to store a piece of metadata, including its name, value, and type.

## Defines the supported data types for metadata.
enum Type {
	TEXT, # String
	JSON, # String that can be parsed as JSON
	VECTOR2, # Vector2  instance
	VECTOR3, # Vector3 instance
	QUATERNION, # Quaternion instance
	COLOR, # Color instance
	BOOLEAN, # bool
	INTEGER, # int
	FLOAT # float
}

var is_valid: bool = true
var name: String
var value: Variant
var type: Type = Type.TEXT

func _init(p_name: String, p_value: Variant, p_type: Type = Type.TEXT):
	self.name = p_name
	self.type = p_type

	# Validate that the provided value's type matches the specified enum type
	if not _is_type_valid(p_value, p_type):
		var expected_type_str := Type.find_key(p_type)
		var received_type_str := type_string(typeof(p_value))

		push_error("Type mismatch for '%s'. Expected %s, but got %s." % [p_name, expected_type_str, received_type_str])
		self.type = Type.TEXT
		self.value = ""
		self.is_valid = false
	else:
		self.value = p_value

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

## Checks if the provided value is compatible with the specified metadata type.
func _is_type_valid(p_value: Variant, p_type: Type) -> bool:
	if p_value == null:
		return false

	var value_type = typeof(p_value)
	match p_type:
		Type.TEXT:
			return value_type == TYPE_STRING
		Type.JSON:
			# For JSON, value must be a string and it must be valid JSON.
			if value_type != TYPE_STRING:
				return false

			# An empty string is not valid JSON
			if p_value.is_empty():
				return false

			return JSON.parse_string(p_value) != null
		Type.VECTOR2:
			return value_type == TYPE_VECTOR2
		Type.VECTOR3:
			return value_type == TYPE_VECTOR3
		Type.QUATERNION:
			return value_type == TYPE_QUATERNION
		Type.COLOR:
			return value_type == TYPE_COLOR
		Type.BOOLEAN:
			return value_type == TYPE_BOOL
		Type.INTEGER:
			return value_type == TYPE_INT
		Type.FLOAT:
			return value_type == TYPE_FLOAT
	return false

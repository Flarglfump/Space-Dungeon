class_name Map2D

# Container for data
var _data: Array[int]

var _width: int = 0
var _height: int = 0

func _init(width: int, height: int):
	_width = width
	_height = height
	_data = Array()
	_data.resize(_width * _height)

func get_at(x: int, y: int) -> int:
	assert(x >= 0 and x < _width and y >= 0 and y < _height, "Map2D.get_at: Coordinates out of bounds")
	return _data[x + y * _width]

func set_at(x: int, y: int, value: int) -> void:
	assert(x >= 0 and x < _width and y >= 0 and y < _height, "Map2D.set_at: Coordinates out of bounds")
	_data[x + y * _width] = value
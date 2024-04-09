extends Node2D
class_name LevelGenerator2D

# Vars
## Width of map
@export var _width : int = 96
## Height of map
@export var _height : int = 64
## Width of border
@export var _borderWidth : int = 3
## Required adjacent tiles to spawn wall tile
@export var _WALLTHRESHOLD : int = 4

## Smoothing level modifier
@export var _smoothing : int = 3

## 2D array of map cells
var _map : Map2D
## Tile Map referenced in generation
var _tileMap : TileMap
## Random number generator used to create noise
var _randomNumberGenerator : RandomNumberGenerator
## Range of randomly-generated values
@export var _randomNumberRange : Array[float] = range(0, 1)

## enum for tile type
enum _TileType {
	WALL,
	OPEN,
	UNKNOWN
}
## Max Cutoff values for tile types (in non-decreasing order)
var _TileCutoffVals : Array[float] = [
	0.4, ## WALL
	1 ## OPEN
]


# MAIN
## Call directly after object instantiation
func _ready() -> void:
	_initialize()
	_generateMap()
	_updateTilemap()
	pass


# INIT
## Initialize stuff
func _initialize() -> void:
	_gatherReq()
	_setup()

## Set up dependencies
func _setup() -> void:
	_map = Map2D.new(_width, _height)
	_randomNumberGenerator = RandomNumberGenerator.new()

## Collect dependencies
func _gatherReq() -> void:
	_tileMap = get_node("Map")
	pass


# GENERATION
## Generates initial map
func _generateMap() -> void:
	for x : int in range(_width):
		for y : int in range(_height):
			if _isBorderTile(x, y):
				_map.set_at(x, y, _TileType.WALL)
			else:
				_map.set_at(x, y, _getRandomTile())
	for i : int in range(_smoothing):
		_smoothMap()
## Updates tileMap cells 
func _updateTilemap() -> void:
	for x : int in range(_width):
		for y : int in range(_height):
			if (_map.get_at(x, y) == _TileType.OPEN): continue
			_tileMap.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 0))
## Performs smoothing operation on map
func _smoothMap() -> void:
	var temp : Map2D = Map2D.new(_width, _height)
	for x : int in range(_width):
		for y: int in range(_height):
			var numWalls : int = _getNeighboringWallCount(x, y)
			temp.set_at(x, y, 
				_TileType.WALL if numWalls > _WALLTHRESHOLD else
				_TileType.OPEN if numWalls < _WALLTHRESHOLD else
				_map.get_at(x,y)
			)
	_map = temp

## Returns true if tile at (x,y) is a border tile, else false	
func _isBorderTile(x : int, y : int) -> bool:
	return (
		(x < _borderWidth) ||
		(x > _width - _borderWidth - 1) ||
		(y < _borderWidth) ||
		(y > _height - _borderWidth - 1)
	)
## Returns number of neighboring walls neighboring specified tile
func _getNeighboringWallCount(x : int, y : int) -> int:
	var count : int = 0
	
	for i : int in range(y + 1, y - 2, -1):
		for j : int in range(x + 1, x - 2, -1):
			if _isInBounds(j, i):
				if !(i == y && j == x):	
					count += (
						1 if _map.get_at(j, i) == _TileType.WALL
						else 0
					)
			else:
				count += 1
	return count
## Returns true if tile at position is in bounds, false if not
func _isInBounds(x : int, y : int) -> bool:
	return (
		x >= 0 &&
		x < _width &&
		y >= 0 &&
		y < _height
	)

## Generates random float in range specified by _randomNumberRange, then call _determineTileType()
func _getRandomTile() -> _TileType:
	return _determineTileType(_randomNumberGenerator.randf_range(_randomNumberRange[0], _randomNumberRange[1]))
## Determine tile type based on provided value
func _determineTileType(randVal: float) -> _TileType:
	assert(_TileType.size() >= _TileCutoffVals.size() + 1, "TileType enum must contain at least one element more than TileCutoffVals array.")
	for i : int in range(_TileCutoffVals.size()):
		if randVal <= _TileCutoffVals[i]:
			return _TileType.get(i)
	return _TileType.get(_TileType.size() - 1)

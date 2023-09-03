extends Node
class_name HexDirection

enum {
	NE, E, SE, SW, W, NW
}


static func opposite(direction):
	var result: int = 0
	
	if direction < 3:
		result = direction + 3
	else:
		result = direction - 3
	
	return result

static func previous(direction: int) -> int:
	var result = 0
	
	if direction == HexDirection.NE:
		result = HexDirection.NW
	else:
		result = direction - 1
	
	return result

static func next(direction: int) -> int:
	var result = 0
	
	if direction == HexDirection.NW:
		result = HexDirection.NE
	else:
		result = direction + 1
	
	return result




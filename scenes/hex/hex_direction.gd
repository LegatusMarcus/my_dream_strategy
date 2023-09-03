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


extends Node2D

enum CellType { EMPTY, ACTOR, OBSTACLE, OBJECT }
enum ObjType { NONE, LEVER, TELEPORTER }
#warning-ignore:unused_class_variable
export(CellType) var type = CellType.ACTOR
export(ObjType) var obj_type = ObjType.NONE

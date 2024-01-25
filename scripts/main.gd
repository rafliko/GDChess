extends Node2D

var piece = preload("res://scenes/piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():		
	var instance
	
	for x in range(8):
		for y in range(8):
			if global.board[y][x] == '0': continue
			instance = piece.instantiate()
			instance.pos = {'x':x,'y':y}
			instance.set("value",global.board[y][x])
			if global.isUpperCase(global.board[y][x][0]): #uppercase - white
				instance.get_node("Sprite2D").texture = load("res://textures/white/"+global.board[y][x]+".png")
			else: #lowercase - black
				instance.get_node("Sprite2D").texture = load("res://textures/black/"+global.board[y][x]+".png")
			$Pieces.add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

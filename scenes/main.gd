extends Node2D

var piece = preload("res://scenes/piece.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var instance
	print(Global.board)
	
	for x in range(8):
		for y in range(8):
			if Global.board[y][x] == '0': continue
			instance = piece.instantiate()
			instance.pos = {'x':x,'y':y}
			instance.set("value",Global.board[y][x])
			if Global.isUpperCase(Global.board[y][x][0]): #uppercase - white
				instance.get_node("Sprite2D").texture = load("res://textures/white/"+Global.board[y][x]+".png")
			else: #lowercase - black
				instance.get_node("Sprite2D").texture = load("res://textures/black/"+Global.board[y][x]+".png")
			$Pieces.add_child(instance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

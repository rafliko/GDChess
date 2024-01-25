extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$single.button_down.connect(_singleplayer_clicked)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Chessboard.position += Vector2.LEFT * 0.3
	$Chessboard.position += Vector2.UP * 0.3
	if $Chessboard.position.x <= -(global.unit*8): $Chessboard.position = Vector2(0,0)

func _singleplayer_clicked():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

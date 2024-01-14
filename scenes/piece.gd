extends Node2D

var value = null
var pos = {'x':0,'y':0}
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(pos.x*Global.unit,pos.y*Global.unit)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		position = get_viewport().get_mouse_position()-Vector2(Global.unit/2,Global.unit/2)
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if $Sprite2D.get_rect().has_point(to_local(event.position)) and Global.isUpperCase(value):
			$Sprite2D.z_index = 1
			moving = true
			print("clicked: "+value)
			
	if event is InputEventMouseButton and event.is_released():
		if not moving: return
		Global.board[pos.y][pos.x] = '0'
		pos = {'x':round(position.x/Global.unit),'y':round(position.y/Global.unit)}
		if pos.x<0: pos.x = 0
		if pos.x>7: pos.x = 7
		if pos.y<0: pos.y = 0
		if pos.y>7: pos.y = 7
		for c in get_node("..").get_children():
			if c.pos.x == pos.x and c.pos.y == pos.y and c != get_node('.'): c.queue_free()
		Global.board[pos.y][pos.x] = value
		position = Vector2(pos.x*Global.unit,pos.y*Global.unit)
		$Sprite2D.z_index = 0
		moving = false

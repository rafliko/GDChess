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
		var prevpos = pos
		pos = {'x':round(position.x/Global.unit),'y':round(position.y/Global.unit)}
		if pos.x<0 or pos.x>7 or pos.y<0 or pos.y>7: pos = prevpos
		if not checkLegal(prevpos, pos): pos = prevpos
		for c in get_node("..").get_children():
			if c.pos.x == pos.x and c.pos.y == pos.y and c != get_node('.'): c.queue_free()
		Global.board[prevpos.y][prevpos.x] = '0'
		Global.board[pos.y][pos.x] = value
		position = Vector2(pos.x*Global.unit,pos.y*Global.unit)
		$Sprite2D.z_index = 0
		moving = false

func checkLegal(prevpos, newpos):
	if Global.isUpperCase(Global.board[newpos.y][newpos.x]): return false
	
	if value=='P':
		if (newpos.y >= prevpos.y or 
		(prevpos.y!=6 and prevpos.y-newpos.y > 1) or 
		(prevpos.y==6 and prevpos.y-newpos.y > 2) or 
		(prevpos.x != newpos.x and Global.board[newpos.y][newpos.x] == '0') or 
		(Global.board[newpos.y][newpos.x] != '0' and abs(prevpos.x-newpos.x)>1) or 
		(prevpos.x == newpos.x and Global.board[newpos.y][newpos.x] != '0')): 
			return false
	elif value=='R':
		if newpos.x!=prevpos.x and newpos.y!=prevpos.y:
			return false
		if newpos.x<prevpos.x:
			var y = newpos.y
			for x in range(newpos.x+1,prevpos.x):
				if(Global.board[y][x]!='0'): return false
		elif newpos.x>prevpos.x:
			var y = newpos.y
			for x in range(prevpos.x+1,newpos.x):
				if(Global.board[y][x]!='0'): return false
		elif newpos.y<prevpos.y:
			var x = newpos.x
			for y in range(newpos.y+1,prevpos.y):
				if(Global.board[y][x]!='0'): return false
		elif newpos.y>prevpos.y:
			var x = newpos.x
			for y in range(prevpos.y+1,newpos.y):
				if(Global.board[y][x]!='0'): return false
	elif value=='B':
		if abs(newpos.x-prevpos.x)!=abs(newpos.y-prevpos.y):
			return false
		if newpos.x<prevpos.x && newpos.y<prevpos.y:
			for x in range(newpos.x+1,prevpos.x):
				for y in range(newpos.y+1,prevpos.y):
					if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
		elif newpos.x>prevpos.x && newpos.y<prevpos.y:
			for x in range(prevpos.x+1,newpos.x):
				for y in range(newpos.y+1,prevpos.y):
					if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
		elif newpos.x<prevpos.x && newpos.y>prevpos.y:
			for x in range(newpos.x+1,prevpos.x):
				for y in range(prevpos.y+1,newpos.y):
					if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
		elif newpos.x>prevpos.x && newpos.y>prevpos.y:
			for x in range(prevpos.x+1,newpos.x):
				for y in range(prevpos.y+1,newpos.y):
					if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
	elif value=='N':
		if (not (abs(newpos.x - prevpos.x) == 2 and abs(newpos.y - prevpos.y) == 1) and 
			not (abs(newpos.x - prevpos.x) == 1 and abs(newpos.y - prevpos.y) == 2)):
			return false
	elif value=='K':
		if abs(newpos.x - prevpos.x) > 1 or abs(newpos.y - prevpos.y) > 1:
			return false
	elif value=='Q':
		if (newpos.x!=prevpos.x and newpos.y!=prevpos.y) and abs(newpos.x-prevpos.x)!=abs(newpos.y-prevpos.y):
			return false
			
		if abs(newpos.x-prevpos.x)!=abs(newpos.y-prevpos.y):
			if newpos.x<prevpos.x:
				var y = newpos.y
				for x in range(newpos.x+1,prevpos.x):
					if(Global.board[y][x]!='0'): return false
			elif newpos.x>prevpos.x:
				var y = newpos.y
				for x in range(prevpos.x+1,newpos.x):
					if(Global.board[y][x]!='0'): return false
			elif newpos.y<prevpos.y:
				var x = newpos.x
				for y in range(newpos.y+1,prevpos.y):
					if(Global.board[y][x]!='0'): return false
			elif newpos.y>prevpos.y:
				var x = newpos.x
				for y in range(prevpos.y+1,newpos.y):
					if(Global.board[y][x]!='0'): return false
		else:
			if newpos.x<prevpos.x && newpos.y<prevpos.y:
				for x in range(newpos.x+1,prevpos.x):
					for y in range(newpos.y+1,prevpos.y):
						if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
			elif newpos.x>prevpos.x && newpos.y<prevpos.y:
				for x in range(prevpos.x+1,newpos.x):
					for y in range(newpos.y+1,prevpos.y):
						if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
			elif newpos.x<prevpos.x && newpos.y>prevpos.y:
				for x in range(newpos.x+1,prevpos.x):
					for y in range(prevpos.y+1,newpos.y):
						if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
			elif newpos.x>prevpos.x && newpos.y>prevpos.y:
				for x in range(prevpos.x+1,newpos.x):
					for y in range(prevpos.y+1,newpos.y):
						if(abs(newpos.x-x)==abs(newpos.y-y) && Global.board[y][x]!='0'): return false
	return true

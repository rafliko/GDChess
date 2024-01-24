extends Node2D

var value = null
var pos = {'x':0,'y':0}
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	position = Vector2(pos.x*Global.unit, pos.y*Global.unit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving:
		position = get_viewport().get_mouse_position()-Vector2(Global.unit/2,Global.unit/2)
		
func _on_request_completed(result, response_code, headers, body):
	#stockfish move
	var json = JSON.parse_string(body.get_string_from_utf8())
	if(json["data"].substr(0,8) != 'bestmove'): return
	print(json["data"].substr(9,4))
	var prevpos = {'x':0, 'y':0}
	var newpos = {'x':0, 'y':0}
	Global.moveToBoard(json["data"].substr(9,4),prevpos,newpos)
	for c in get_node("..").get_children():
		if c.pos.x == prevpos.x and c.pos.y == prevpos.y: 
			c.pos = newpos
			if c.value == 'p' and c.pos.y == 7: #promote
				c.value = 'q'
				Global.board[c.pos.y][c.pos.x] = c.value
				c.get_node("Sprite2D").texture = load("res://textures/black/"+c.value+".png")
			if c.value == 'k' and newpos.x - prevpos.x == 2: #castling kingside
				Global.kcastling = false
				Global.qcastling = false
				Global.board[0][7] = '0'
				Global.board[0][newpos.x-1] = 'r'
				for c2 in get_node("..").get_children():
					if c2.pos.x == 7 and c2.pos.y == 0:
						c2.pos.x = newpos.x-1
						c2.position = Vector2(c2.pos.x*Global.unit, c2.pos.y*Global.unit)
			if c.value == 'k' and newpos.x - prevpos.x == -2: #castling queenside
				Global.kcastling = false
				Global.qcastling = false
				Global.board[0][0] = '0'
				Global.board[0][newpos.x+1] = 'r'
				for c2 in get_node("..").get_children():
					if c2.pos.x == 0 and c2.pos.y == 0:
						c2.pos.x = newpos.x+1
						c2.position = Vector2(c2.pos.x*Global.unit, c2.pos.y*Global.unit)
			if c.value == 'r' and prevpos.x == 0: Global.qcastling = false
			elif c.value == 'r' and prevpos.x == 7: Global.kcastling = false
				
			c.position = Vector2(c.pos.x*Global.unit, c.pos.y*Global.unit)
		elif c.pos.x == newpos.x and c.pos.y == newpos.y:
			c.queue_free()
	Global.turn = 'w'
	print(Global.boardToFen())
	$AudioStreamPlayer2D.play()

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
		else:
			for c in get_node("..").get_children():
				if c.pos.x == pos.x and c.pos.y == pos.y and c != get_node('.'): 
					c.queue_free()
			if value=='P' and pos.y == 0: #promote
				value = 'Q'
				get_node("Sprite2D").texture = load("res://textures/white/"+value+".png")
			Global.turn = 'b'
			Global.board[prevpos.y][prevpos.x] = '0'
			Global.board[pos.y][pos.x] = value
			print(Global.boardToFen())
			$HTTPRequest.request('https://stockfish.online/api/stockfish.php?fen='+Global.boardToFen()+'&depth=1&mode=bestmove')
			$AudioStreamPlayer2D.play()
		position = Vector2(pos.x*Global.unit,pos.y*Global.unit)
		$Sprite2D.z_index = 0
		moving = false

func checkLegal(prevpos, newpos):
	if Global.isUpperCase(Global.board[newpos.y][newpos.x]) or Global.turn == 'b': 
		return false
		
	#check for check
	#############################################################################
	
	var tmpboard = Global.board.duplicate(true)
	tmpboard[prevpos.y][prevpos.x] = '0'
	tmpboard[newpos.y][newpos.x] = value

	#horizontal/vertical
	var kingpos = {'x':0, 'y':0}
	for x in range(8):
		for y in range(8):
			if(tmpboard[y][x]=='K'):
				kingpos.x = x
				kingpos.y = y

	for x in range(kingpos.x+1,8):
		if(tmpboard[kingpos.y][x]!='0'): 
			if(tmpboard[kingpos.y][x]=='r' or tmpboard[kingpos.y][x]=='q'):
				return false
			else: break
	for x in range(kingpos.x-1,-1,-1):
		if(tmpboard[kingpos.y][x]!='0'): 
			if(tmpboard[kingpos.y][x]=='r' or tmpboard[kingpos.y][x]=='q'):
				return false
			else: break
	for y in range(kingpos.y+1,8):
		if(tmpboard[y][kingpos.x]!='0'): 
			if(tmpboard[y][kingpos.x]=='r' or tmpboard[y][kingpos.x]=='q'):
				return false
			else: break
	for y in range(kingpos.y-1,-1,-1):
		if(tmpboard[y][kingpos.x]!='0'): 
			if(tmpboard[y][kingpos.x]=='r' or tmpboard[y][kingpos.x]=='q'):
				return false
			else: break
	
	#diagonal
	var breaker = false
	
	for x in range(kingpos.x+1,8):
		for y in range(kingpos.y+1,8):
			if(abs(kingpos.x-x)==abs(kingpos.y-y) && tmpboard[y][x]!='0'):
				if(tmpboard[y][x]=='b' or tmpboard[y][x]=='q'):
					return false
				else: 
					breaker = true
					break
		if breaker:
			breaker = false
			break
	for x in range(kingpos.x-1,-1,-1):
		for y in range(kingpos.y+1,8):
			if(abs(kingpos.x-x)==abs(kingpos.y-y) && tmpboard[y][x]!='0'):
				if(tmpboard[y][x]=='b' or tmpboard[y][x]=='q'):
					return false
				else: 
					breaker = true
					break
		if breaker:
			breaker = false
			break
	for x in range(kingpos.x+1,8):
		for y in range(kingpos.y-1,-1,-1):
			if(abs(kingpos.x-x)==abs(kingpos.y-y) && tmpboard[y][x]!='0'):
				if(tmpboard[y][x]=='b' or tmpboard[y][x]=='q'):
					return false
				else: 
					breaker = true
					break
		if breaker:
			breaker = false
			break
	for x in range(kingpos.x-1,-1,-1):
		for y in range(kingpos.y-1,-1,-1):
			if(abs(kingpos.x-x)==abs(kingpos.y-y) && tmpboard[y][x]!='0'):
				if(tmpboard[y][x]=='b' or tmpboard[y][x]=='q'):
					return false
				else: 
					breaker = true
					break
		if breaker:
			breaker = false
			break
	
	#knight
	if ((kingpos.y<6 and kingpos.x<7 and tmpboard[kingpos.y+2][kingpos.x+1]=='n') or
		(kingpos.y>1 and kingpos.x<7 and tmpboard[kingpos.y-2][kingpos.x+1]=='n') or
		(kingpos.y<6 and kingpos.x>0 and tmpboard[kingpos.y+2][kingpos.x-1]=='n') or
		(kingpos.y>1 and kingpos.x>0 and tmpboard[kingpos.y-2][kingpos.x-1]=='n') or
		(kingpos.y<7 and kingpos.x<6 and tmpboard[kingpos.y+1][kingpos.x+2]=='n') or
		(kingpos.y>0 and kingpos.x<6 and tmpboard[kingpos.y-1][kingpos.x+2]=='n') or
		(kingpos.y<7 and kingpos.x>1 and tmpboard[kingpos.y+1][kingpos.x-2]=='n') or
		(kingpos.y>0 and kingpos.x>1) and tmpboard[kingpos.y-1][kingpos.x-2]=='n'):
			return false
	
	#pawn
	if (kingpos.y>0 and 
		(kingpos.x<7 and tmpboard[kingpos.y-1][kingpos.x+1]=='p') or 
		(kingpos.x>0 and tmpboard[kingpos.y-1][kingpos.x-1]=='p')):
		return false
		
	#king
	if ((kingpos.x<7 and tmpboard[kingpos.y][kingpos.x+1]=='k') or 
		(kingpos.x>0 and tmpboard[kingpos.y][kingpos.x-1]=='k') or
		(kingpos.y<7 and tmpboard[kingpos.y+1][kingpos.x]=='k') or
		(kingpos.y>0 and tmpboard[kingpos.y-1][kingpos.x]=='k') or
		(kingpos.x<7 and kingpos.y<7 and tmpboard[kingpos.y+1][kingpos.x+1]=='k') or
		(kingpos.x>0 and kingpos.y<7 and tmpboard[kingpos.y+1][kingpos.x-1]=='k') or
		(kingpos.x<7 and kingpos.y>0 and tmpboard[kingpos.y-1][kingpos.x+1]=='k') or
		(kingpos.x>0 and kingpos.y>0 and tmpboard[kingpos.y-1][kingpos.x-1]=='k')):
		return false
	
	#############################################################################
	
	#check move
	#############################################################################
	
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
		
		#castling
		if prevpos.x == 7 and prevpos.y==7:
			Global.Kcastling = false
		elif prevpos.x == 0 and prevpos.y==7:
			Global.Qcastling = false
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
		#castling
		if (Global.Kcastling and newpos.x - prevpos.x == 2 and 
			prevpos.y == newpos.y and 
			Global.board[newpos.y][newpos.x-1]=='0' and
			Global.board[newpos.y][newpos.x]=='0'):
			Global.Kcastling = false
			Global.Qcastling = false
			Global.board[7][7] = '0'
			Global.board[7][newpos.x-1] = 'R'
			for c in get_node("..").get_children():
				if c.pos.x == 7 and c.pos.y == 7:
					c.pos.x = newpos.x-1
					c.position = Vector2(c.pos.x*Global.unit, c.pos.y*Global.unit)
			return true
		if (Global.Qcastling and newpos.x - prevpos.x == -2 and 
			prevpos.y == newpos.y and 
			Global.board[newpos.y][newpos.x+1]=='0' and
			Global.board[newpos.y][newpos.x]=='0'):
			Global.Kcastling = false
			Global.Qcastling = false
			Global.board[7][0] = '0'
			Global.board[7][newpos.x+1] = 'R'
			for c in get_node("..").get_children():
				if c.pos.x == 0 and c.pos.y == 7:
					c.pos.x = newpos.x+1
					c.position = Vector2(c.pos.x*Global.unit, c.pos.y*Global.unit)
			return true
		
		if abs(newpos.x - prevpos.x) > 1 or abs(newpos.y - prevpos.y) > 1:
			return false
		else:
			Global.Kcastling = false
			Global.Qcastling = false
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
	
	#############################################################################
	
	return true

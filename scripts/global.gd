extends Node

var board = [ 
	['r','n','b','q','k','b','n','r'],
	['p','p','p','p','p','p','p','p'],
	['0','0','0','0','0','0','0','0'],
	['0','0','0','0','0','0','0','0'],
	['0','0','0','0','0','0','0','0'],
	['0','0','0','0','0','0','0','0'],
	['P','P','P','P','P','P','P','P'],
	['R','N','B','Q','K','B','N','R'],
]

var unit = 96

var turn = 'w'
var playercolor = 'w'
var aicolor = 'b'

var Kcastling = true
var Qcastling = true
var kcastling = true
var qcastling = true

func isUpperCase(char):
	if char >= 'A' and char <= 'Z': return true
	else: return false

func boardToFen():
	var fenstring = ''
	var emptycount = 0
	for y in range(8):
		for x in range(8):
			if board[y][x] == '0': emptycount+=1
			else:
				if emptycount>0:
					fenstring+=str(emptycount)
					emptycount = 0
				fenstring+=board[y][x]
		if emptycount>0:
			fenstring+=str(emptycount)
			emptycount = 0
		if y<7: fenstring+='/'
	
	var castling = ''
	if Kcastling: castling+='K'
	if Qcastling: castling+='Q'
	if kcastling: castling+='k'
	if qcastling: castling+='q'
	if not Kcastling and not Qcastling and not kcastling and not qcastling: 
		castling+='-'
	fenstring += ' '+turn+' '+castling+' - 0 1'
	
	return fenstring

func moveToBoard(move, prevpos, newpos):	
	prevpos.x = move.unicode_at(0)-97
	prevpos.y = 8 - int(move[1])
	newpos.x = move.unicode_at(2)-97
	newpos.y = 8 - int(move[3])
	
	board[newpos.y][newpos.x] = board[prevpos.y][prevpos.x]
	board[prevpos.y][prevpos.x] = '0'

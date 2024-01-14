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

func isUpperCase(char):
	if char >= 'A' and char <= 'Z': return true
	else: return false

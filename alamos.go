package main

import (
	"fmt"
	"os"
)

const HIGH_VALUE = 100000
const SEARCH_DEPTH = 6

const (
	EMPTY = 0
	wP    = 1
	bP    = -1
	wN    = 2
	bN    = -2
	wR    = 3
	bR    = -3
	wQ    = 4
	bQ    = -4
	wK    = 5
	bK    = -5
)

func evaluateBoard(board []int) int {
	var pieceValues = []int{
		-10000, -900, -500, -300, -100,
		0,
		100, 300, 500, 900, 10000,
	}
	score := 0
	for _, piece := range board {
		score += pieceValues[piece+5]
	}

	return score
}

func contains(s []int, e int) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func getKnightMoves(position [2]int, board []int) [][2]int {
	offsets := [][2]int{{2, 1}, {1, 2}, {-2, 1}, {-1, 2}, {2, -1}, {1, -2}, {-2, -1}, {-1, -2}}
	var moves [][2]int

	piece := board[position[0]*6+position[1]]
	for _, offset := range offsets {
		nx, ny := position[0]+offset[0], position[1]+offset[1]
		if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
			target := board[nx*6+ny]
			if target == EMPTY || target*piece < 0 {
				moves = append(moves, [2]int{nx, ny})
			}
		}
	}

	return moves
}

func getRookMoves(position [2]int, board []int) [][2]int {
	directions := [][2]int{{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
	var moves [][2]int
	piece := board[position[0]*6+position[1]]
	for _, direction := range directions {
		nx, ny := position[0], position[1]
		for {
			nx, ny = nx+direction[0], ny+direction[1]
			if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
				target := board[nx*6+ny]
				if target == EMPTY {
					moves = append(moves, [2]int{nx, ny})
					continue
				}
				if target*piece < 0 {
					moves = append(moves, [2]int{nx, ny})
				}
			}
			break
		}
	}
	return moves
}

func getQueenMoves(position [2]int, board []int) [][2]int {
	diagonalDirections := [][2]int{{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
	var moves [][2]int
	piece := board[position[0]*6+position[1]]
	for _, direction := range diagonalDirections {
		nx, ny := position[0], position[1]
		for {
			nx, ny = nx+direction[0], ny+direction[1]
			if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
				target := board[nx*6+ny]
				if target == EMPTY {
					moves = append(moves, [2]int{nx, ny})
					continue
				}
				if target*piece < 0 {
					moves = append(moves, [2]int{nx, ny})
				}
			}
			break
		}
	}
	moves = append(moves, getRookMoves(position, board)...)
	return moves
}

func getKingMoves(position [2]int, board []int) [][2]int {
	offsets := [][2]int{{1, 0}, {0, 1}, {-1, 0}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
	var moves [][2]int
	piece := board[position[0]*6+position[1]]
	for _, offset := range offsets {
		nx, ny := position[0]+offset[0], position[1]+offset[1]
		if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
			target := board[nx*6+ny]
			if target == EMPTY || target*piece < 0 {
				moves = append(moves, [2]int{nx, ny})
			}
		}
	}

	return moves
}

func getPawnMoves(position [2]int, board []int) [][2]int {
	var moves [][2]int
	x, y := position[0], position[1]
	piece := board[x*6+y]

  dx := 1
	if piece > 0 {
    dx = -1
	}

	if x+dx >= 0 && x+dx < 6 {
		if board[(x+dx)*6+y] == EMPTY {
			moves = append(moves, [2]int{x + dx, y})
		}

		for _, dy := range []int{-1, 1} {
			if y+dy >= 0 && y+dy < 6 {
				target := board[(x+dx)*6+y+dy]
				if target != EMPTY && target*piece < 0 {
					moves = append(moves, [2]int{x + dx, y + dy})
				}
			}
		}
	}

	return moves
}

func makeMove(board []int, position [2]int, move [2]int) []int {
	posIdx := position[0]*6 + position[1]
	moveIdx := move[0]*6 + move[1]
	piece := board[posIdx]

	newBoard := make([]int, len(board))
	copy(newBoard, board)

	newBoard[posIdx] = EMPTY
	newBoard[moveIdx] = piece

	if piece == wP && move[0] == 5 {
		newBoard[moveIdx] = wQ
	} else if piece == bP && move[0] == 0 {
		newBoard[moveIdx] = bQ
	}

	return newBoard
}

func getMoves(idx int, piece int, board []int) [][2]int {
	var moves [][2]int
	position := [2]int{idx / 6, idx % 6}

	switch piece {
	case wP, bP:
		moves = getPawnMoves(position, board)
	case wR, bR:
		moves = getRookMoves(position, board)
	case wN, bN:
		moves = getKnightMoves(position, board)
	case wQ, bQ:
		moves = getQueenMoves(position, board)
	case wK, bK:
		moves = getKingMoves(position, board)
	}

	return moves
}

func negamax(board []int, depth, alpha, beta, color int) ([]int, int) {
	if depth == 0 || !contains(board, wK) || !contains(board, bK) {
		return board, color * evaluateBoard(board)
	}

	bestValue := -HIGH_VALUE
	bestBoard := board

	for idx, piece := range board {
		if (color == 1 && piece > 0) || (color == -1 && piece < 0) {
			moves := getMoves(idx, piece, board)
			for _, move := range moves {
				newBoard := makeMove(board, [2]int{idx / 6, idx % 6}, move)
				_, moveValue := negamax(newBoard, depth-1, -beta, -alpha, -color)
				moveValue = -moveValue

				if moveValue > bestValue {
					bestValue = moveValue
					bestBoard = newBoard
				}

				if bestValue > alpha {
					alpha = bestValue
				}
				if alpha >= beta {
					break
				}
			}
		}
	}
	return bestBoard, bestValue
}

func stringToIntBoard(board string) []int {
	intBoard := make([]int, 36)
	for i, piece := range board {
		switch piece {
		case '.':
			intBoard[i] = EMPTY
		case 'P':
			intBoard[i] = wP
		case 'p':
			intBoard[i] = bP
		case 'R':
			intBoard[i] = wR
		case 'r':
			intBoard[i] = bR
		case 'N':
			intBoard[i] = wN
		case 'n':
			intBoard[i] = bN
		case 'Q':
			intBoard[i] = wQ
		case 'q':
			intBoard[i] = bQ
		case 'K':
			intBoard[i] = wK
		case 'k':
			intBoard[i] = bK
		}
	}
	return intBoard
}

func intToStringBoard(intBoard []int) string {
	board := make([]rune, 36)
	for i, piece := range intBoard {
		switch piece {
		case EMPTY:
			board[i] = '.'
		case wP:
			board[i] = 'P'
		case bP:
			board[i] = 'p'
		case wR:
			board[i] = 'R'
		case bR:
			board[i] = 'r'
		case wN:
			board[i] = 'N'
		case bN:
			board[i] = 'n'
		case wQ:
			board[i] = 'Q'
		case bQ:
			board[i] = 'q'
		case wK:
			board[i] = 'K'
		case bK:
			board[i] = 'k'
		}
	}
	return string(board)
}

func main() {
	inputBoard := stringToIntBoard(os.Args[1])
	board, _ := negamax(inputBoard, SEARCH_DEPTH, -HIGH_VALUE, HIGH_VALUE,
		func() int {
			if os.Args[2] == "w" {
				return 1
			}
			return -1
		}(),
	)

	nextTurn := "w"
	if os.Args[2] == "w" {
		nextTurn = "b"
	}
	fmt.Println(intToStringBoard(board), nextTurn)
}

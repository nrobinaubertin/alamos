package main

import (
	"fmt"
	"os"
	"strings"
	"unicode"
)

const HIGH_VALUE = 100000
const SEARCH_DEPTH = 6

func sameCase(a, b byte) bool {
	return (unicode.IsUpper(rune(a)) && unicode.IsUpper(rune(b))) || (unicode.IsLower(rune(a)) && unicode.IsLower(rune(b)))
}

func getKnightMoves(position [2]int, board string) [][2]int {
	offsets := [][2]int{{2, 1}, {1, 2}, {-2, 1}, {-1, 2}, {2, -1}, {1, -2}, {-2, -1}, {-1, -2}}
	var moves [][2]int

	piece := board[position[0]*6+position[1]]
	for _, offset := range offsets {
		nx, ny := position[0]+offset[0], position[1]+offset[1]
		if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
			target := board[nx*6+ny]
			if target == '.' || !sameCase(target, piece) {
				moves = append(moves, [2]int{nx, ny})
			}
		}
	}

	return moves
}

func getRookMoves(position [2]int, board string) [][2]int {
	directions := [][2]int{{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
	var moves [][2]int

	piece := board[position[0]*6+position[1]]
	for _, direction := range directions {
		nx, ny := position[0], position[1]
		for {
			nx, ny = nx+direction[0], ny+direction[1]
			if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
				target := board[nx*6+ny]
				if target == '.' {
					moves = append(moves, [2]int{nx, ny})
					continue
				}
				if !sameCase(target, piece) {
					moves = append(moves, [2]int{nx, ny})
				}
			}
			break
		}
	}
	return moves
}

func getQueenMoves(position [2]int, board string) [][2]int {
	diagonalDirections := [][2]int{{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
	var moves [][2]int

	piece := board[position[0]*6+position[1]]
	for _, direction := range diagonalDirections {
		nx, ny := position[0], position[1]
		for {
			nx, ny = nx+direction[0], ny+direction[1]
			if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
				target := board[nx*6+ny]
				if target == '.' {
					moves = append(moves, [2]int{nx, ny})
					continue
				}
				if !sameCase(target, piece) {
					moves = append(moves, [2]int{nx, ny})
				}
			}
			break
		}
	}
	// Adding rook moves to diagonal moves
	moves = append(moves, getRookMoves(position, board)...)
	return moves
}

func getKingMoves(position [2]int, board string) [][2]int {
	offsets := [][2]int{{1, 0}, {0, 1}, {-1, 0}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
	var moves [][2]int

	piece := board[position[0]*6+position[1]]
	for _, offset := range offsets {
		nx, ny := position[0]+offset[0], position[1]+offset[1]
		if nx >= 0 && nx < 6 && ny >= 0 && ny < 6 {
			target := board[nx*6+ny]
			if target == '.' || !sameCase(target, piece) {
				moves = append(moves, [2]int{nx, ny})
			}
		}
	}

	return moves
}

func getPawnMoves(position [2]int, board string) [][2]int {
	var moves [][2]int
	x, y := position[0], position[1]
	piece := board[x*6+y]

	var dx int
	if piece == 'p' {
		dx = 1
	} else {
		dx = -1
	}

	// Forward move
	if x+dx >= 0 && x+dx < 6 {
		if board[(x+dx)*6+y] == '.' {
			moves = append(moves, [2]int{x + dx, y})
		}

		// Capture moves
		for _, dy := range []int{-1, 1} {
			if y+dy >= 0 && y+dy < 6 {
				target := board[(x+dx)*6+y+dy]
				if target != '.' && !sameCase(target, piece) {
					moves = append(moves, [2]int{x + dx, y + dy})
				}
			}
		}
	}

	return moves
}

func evaluateBoard(board string) int {
	pieceValues := map[rune]int{
		'p': -100, 'P': 100,
		'n': -300, 'N': 300,
		'r': -500, 'R': 500,
		'q': -900, 'Q': 900,
		'k': -10000, 'K': 10000,
		'.': 0,
	}

	score := 0
	for _, piece := range board {
		score += pieceValues[piece]
	}

	return score
}

func makeMove(board string, position [2]int, move [2]int) string {
	posIdx := position[0]*6 + position[1]
	moveIdx := move[0]*6 + move[1]
	piece := board[posIdx]

	boardArr := []byte(board)
	boardArr[posIdx] = '.'
	boardArr[moveIdx] = byte(piece)

	if piece == 'P' && move[0] == 5 {
		boardArr[moveIdx] = 'Q'
	} else if piece == 'p' && move[0] == 0 {
		boardArr[moveIdx] = 'q'
	}

	return string(boardArr)
}

func getMoves(idx int, piece byte, board string) [][2]int {
	var moves [][2]int
	position := [2]int{idx / 6, idx % 6}

	switch piece {
	case 'P', 'p':
		moves = getPawnMoves(position, board)
	case 'R', 'r':
		moves = getRookMoves(position, board)
	case 'N', 'n':
		moves = getKnightMoves(position, board)
	case 'Q', 'q':
		moves = getQueenMoves(position, board)
	case 'K', 'k':
		moves = getKingMoves(position, board)
	}

	return moves
}

func negamax(board string, depth, alpha, beta, color int) (string, int) {
	if depth == 0 || !strings.Contains(board, "k") || !strings.Contains(board, "K") {
		return board, color * evaluateBoard(board)
	}

	bestValue := -HIGH_VALUE
	bestBoard := board

	for idx, piece := range board {
		if (color == 1 && unicode.IsUpper(rune(piece))) || (color == -1 && unicode.IsLower(rune(piece))) {
			moves := getMoves(idx, byte(piece), board)
			for _, move := range moves {
				newBoard := makeMove(board, [2]int{idx / 6, idx % 6}, move)
				_, moveValue := negamax(newBoard, depth-1, -beta, -alpha, -color)
				moveValue = -moveValue

				if moveValue > bestValue {
					bestValue = moveValue
					bestBoard = newBoard
				}
				alpha = max(alpha, bestValue)
				if alpha >= beta {
					break
				}
			}
		}
	}
	return bestBoard, bestValue
}

func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func main() {
	board, _ := negamax(os.Args[1], SEARCH_DEPTH, -HIGH_VALUE, HIGH_VALUE,
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
	fmt.Println(board, nextTurn)
}

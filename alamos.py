#!/usr/bin/env python3

import sys

HIGH_VALUE = 100000
SEARCH_DEPTH = 6

EMPTY = 0
wP = 1
bP = -1
wN = 2
bN = -2
wR = 3
bR = -3
wQ = 4
bQ = -4
wK = 5
bK = -5


def evaluate_board(board) -> int:
    piece_values = [
        -10000,
        -900,
        -500,
        -300,
        -100,
        0,
        100,
        300,
        500,
        900,
        10000,
    ]
    return sum([piece_values[piece + 5] for piece in board])


def offset_moves(position, board, offsets):
    for dx, dy in offsets:
        nx, ny = position[0] + dx, position[1] + dy
        if 0 <= nx < 6 and 0 <= ny < 6:
            target = board[nx * 6 + ny]
            if target * board[position[0] * 6 + position[1]] <= 0:
                yield (nx, ny)


def get_knight_moves(position, board):
    offsets = ((2, 1), (1, 2), (-2, 1), (-1, 2), (2, -1), (1, -2), (-2, -1), (-1, -2))
    yield from offset_moves(position, board, offsets)


def get_king_moves(position, board):
    offsets = ((1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1))
    yield from offset_moves(position, board, offsets)


def vector_moves(position, board, vectors):
    for dx, dy in vectors:
        nx, ny = position
        while True:
            nx, ny = nx + dx, ny + dy
            if 0 <= nx < 6 and 0 <= ny < 6:
                target = board[nx * 6 + ny]
                if target == EMPTY:
                    yield (nx, ny)
                    continue
                if target * board[position[0] * 6 + position[1]] < 0:
                    yield (nx, ny)
            break


def get_rook_moves(position, board):
    vectors = ((0, 1), (1, 0), (0, -1), (-1, 0))
    yield from vector_moves(position, board, vectors)


def get_queen_moves(position, board):
    vectors = ((1, 1), (1, -1), (-1, 1), (-1, -1))
    yield from vector_moves(position, board, vectors)
    yield from get_rook_moves(position, board)


def get_pawn_moves(position, board):
    x, y = position
    dx = 1 if board[position[0] * 6 + position[1]] < 0 else -1
    if 0 <= x + dx < 6:
        if board[(x + dx) * 6 + y] == EMPTY:
            yield (x + dx, y)
        for dy in (-1, 1):
            if 0 <= y + dy < 6:
                target = board[(x + dx) * 6 + (y + dy)]
                if target * board[position[0] * 6 + position[1]] < 0:
                    yield (x + dx, y + dy)


def make_move(board, position, move):
    new_board = board.copy()
    pos_idx = position[0] * 6 + position[1]
    move_idx = move[0] * 6 + move[1]
    piece = new_board[pos_idx]

    new_board[pos_idx] = EMPTY
    new_board[move_idx] = piece

    if piece == wP and move[0] == 5:
        new_board[move_idx] = wQ
    elif piece == bP and move[0] == 0:
        new_board[move_idx] = bQ

    return new_board


def get_moves(idx, piece, board):
    x, y = idx // 6, idx % 6
    if piece in (wP, bP):
        yield from get_pawn_moves((x, y), board)
    elif piece in (wR, bR):
        yield from get_rook_moves((x, y), board)
    elif piece in (wN, bN):
        yield from get_knight_moves((x, y), board)
    elif piece in (wQ, bQ):
        yield from get_queen_moves((x, y), board)
    elif piece in (wK, bK):
        yield from get_king_moves((x, y), board)
    return


def negamax(board, depth, alpha, beta, color):
    if depth == 0 or wK not in board or bK not in board:
        return board, color * evaluate_board(board)

    best_value = -HIGH_VALUE
    best_board = board

    for idx, piece in enumerate(board):
        if (color == 1 and piece > 0) or (color == -1 and piece < 0):
            for move in get_moves(idx, piece, board):
                new_board = make_move(board, (idx // 6, idx % 6), move)
                _, move_value = negamax(new_board, depth - 1, -beta, -alpha, -color)
                move_value = -move_value
                if move_value > best_value:
                    best_value = move_value
                    best_board = new_board
                alpha = max(alpha, best_value)
                if alpha >= beta:
                    break
        if alpha >= beta:
            break

    return best_board, best_value


char_to_int_map = {
    ".": EMPTY,
    "P": wP,
    "p": bP,
    "R": wR,
    "r": bR,
    "N": wN,
    "n": bN,
    "Q": wQ,
    "q": bQ,
    "K": wK,
    "k": bK,
}


def string_to_int_board(board):
    return [char_to_int_map[piece] for piece in board]


def int_to_string_board(int_board):
    int_to_char_map = {v: k for k, v in char_to_int_map.items()}
    return "".join([int_to_char_map[piece] for piece in int_board])


if __name__ == "__main__":
    board, _ = negamax(
        string_to_int_board(sys.argv[1]),
        SEARCH_DEPTH,
        -HIGH_VALUE,
        HIGH_VALUE,
        1 if sys.argv[2] == "w" else -1,
    )

    print(int_to_string_board(board), "b" if sys.argv[2] == "w" else "w")

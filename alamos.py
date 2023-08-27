#!/usr/bin/env python3

import sys

HIGH_VALUE = 100000
SEARCH_DEPTH = 6

def get_knight_moves(position, board):
    offsets = [(2, 1), (1, 2), (-2, 1), (-1, 2), (2, -1), (1, -2), (-2, -1), (-1, -2)]
    for dx, dy in offsets:
        nx, ny = position[0] + dx, position[1] + dy
        if 0 <= nx < 6 and 0 <= ny < 6:
            target = board[nx * 6 + ny]
            if (
                target == "."
                or target.islower() != board[position[0] * 6 + position[1]].islower()
            ):
                yield (nx, ny)


def get_rook_moves(position, board):
    directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    for dx, dy in directions:
        nx, ny = position
        while True:
            nx, ny = nx + dx, ny + dy
            if 0 <= nx < 6 and 0 <= ny < 6:
                target = board[nx * 6 + ny]
                if target == ".":
                    yield (nx, ny)
                    continue
                if target.islower() != board[position[0] * 6 + position[1]].islower():
                    yield (nx, ny)
            break


def get_queen_moves(position, board):
    directions = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
    for dx, dy in directions:
        nx, ny = position
        while True:
            nx, ny = nx + dx, ny + dy
            if 0 <= nx < 6 and 0 <= ny < 6:
                target = board[nx * 6 + ny]
                if target == ".":
                    yield (nx, ny)
                    continue
                if target.islower() != board[position[0] * 6 + position[1]].islower():
                    yield (nx, ny)
            break
    yield from get_rook_moves(position, board)


def get_king_moves(position, board):
    offsets = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
    for dx, dy in offsets:
        nx, ny = position[0] + dx, position[1] + dy
        if 0 <= nx < 6 and 0 <= ny < 6:
            target = board[nx * 6 + ny]
            if (
                target == "."
                or target.islower() != board[position[0] * 6 + position[1]].islower()
            ):
                yield (nx, ny)


def get_pawn_moves(position, board):
    x, y = position
    dx = 1 if board[position[0] * 6 + position[1]].islower() else -1
    if 0 <= x + dx < 6:
        if board[(x + dx) * 6 + y] == ".":
            yield (x + dx, y)
        for dy in [-1, 1]:
            if 0 <= y + dy < 6:
                target = board[(x + dx) * 6 + (y + dy)]
                if (
                    target != "."
                    and target.islower() != board[position[0] * 6 + position[1]].islower()
                ):
                    yield (x + dx, y + dy)


def evaluate_board(board) -> int:
    piece_values = {
        "p": -100, "P": 100,
        "n": -300, "N": 300,
        "r": -500, "R": 500,
        "q": -900, "Q": 900,
        "k": -10000, "K": 10000,
        ".": 0,
    }
    return sum([piece_values[piece] for piece in board])


def make_move(board, position, move):
    pos_idx = position[0] * 6 + position[1]
    move_idx = move[0] * 6 + move[1]
    board = list(board)
    piece = board[pos_idx]

    board[pos_idx] = "."
    board[move_idx] = piece

    if piece == "P" and move[0] == 5:
        board[move_idx] = "Q"
    elif piece == "p" and move[0] == 0:
        board[move_idx] = "q"

    return "".join(board)


def get_moves(idx, piece, board):
    x, y = idx // 6, idx % 6
    if piece in ["P", "p"]:
        yield from get_pawn_moves((x, y), board)
    elif piece in ["R", "r"]:
        yield from get_rook_moves((x, y), board)
    elif piece in ["N", "n"]:
        yield from get_knight_moves((x, y), board)
    elif piece in ["Q", "q"]:
        yield from get_queen_moves((x, y), board)
    elif piece in ["K", "k"]:
        yield from get_king_moves((x, y), board)
    return


def negamax(board, depth, alpha, beta, color):
    if depth == 0 or "k" not in board or "K" not in board:
        return board, color * evaluate_board(board)

    best_value = -HIGH_VALUE
    best_board = board

    for idx, piece in enumerate(board):
        if (color == 1 and piece.isupper()) or (color == -1 and piece.islower()):
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


if __name__ == "__main__":
    board, _ = negamax(
        sys.argv[1],
        SEARCH_DEPTH,
        -HIGH_VALUE,
        HIGH_VALUE,
        1 if sys.argv[2] == "w" else -1,
    )

    print(board, "b" if sys.argv[2] == "w" else "w")

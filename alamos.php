#!/usr/bin/env php
<?php

define('HIGH_VALUE', 100000);
define('SEARCH_DEPTH', 6);

function offset_moves($position, $board, $offsets) {
    foreach ($offsets as [$dx, $dy]) {
        $nx = $position[0] + $dx;
        $ny = $position[1] + $dy;
        if ($nx >= 0 && $nx < 6 && $ny >= 0 && $ny < 6) {
            $target = $board[$nx * 6 + $ny];
            if (
                $target === '.'
                || ctype_lower($target) !== ctype_lower($board[$position[0] * 6 + $position[1]])
            ) {
                yield [$nx, $ny];
            }
        }
    }
}

function get_knight_moves($position, $board) {
    $offsets = [[2, 1], [1, 2], [-2, 1], [-1, 2], [2, -1], [1, -2], [-2, -1], [-1, -2]];
    yield from offset_moves($position, $board, $offsets);
}

function get_king_moves($position, $board) {
    $offsets = [[1, 0], [0, 1], [-1, 0], [0, -1], [1, 1], [1, -1], [-1, 1], [-1, -1]];
    yield from offset_moves($position, $board, $offsets);
}

function vector_moves($position, $board, $vectors) {
    foreach ($vectors as [$dx, $dy]) {
        $nx = $position[0];
        $ny = $position[1];
        while (true) {
            $nx += $dx;
            $ny += $dy;

            if ($nx >= 0 && $nx < 6 && $ny >= 0 && $ny < 6) {
                $target = $board[$nx * 6 + $ny];
                if ($target === '.') {
                    yield [$nx, $ny];
                    continue;
                }
                if (ctype_lower($target) !== ctype_lower($board[$position[0] * 6 + $position[1]])) {
                    yield [$nx, $ny];
                }
            }
            break;
        }
    }
}

function get_rook_moves($position, $board) {
    $vectors = [[0, 1], [1, 0], [0, -1], [-1, 0]];
    yield from vector_moves($position, $board, $vectors);
}

function get_queen_moves($position, $board) {
    $vectors = [[1, 1], [1, -1], [-1, 1], [-1, -1]];
    yield from vector_moves($position, $board, $vectors);
    yield from get_rook_moves($position, $board);
}

function get_pawn_moves($position, $board) {
    $x = $position[0];
    $y = $position[1];
    $dx = ctype_lower($board[$position[0] * 6 + $position[1]]) ? 1 : -1;

    if ($x + $dx >= 0 && $x + $dx < 6) {
        if ($board[($x + $dx) * 6 + $y] === '.') {
            yield [$x + $dx, $y];
        }
        foreach ([-1, 1] as $dy) {
            if ($y + $dy >= 0 && $y + $dy < 6) {
                $target = $board[($x + $dx) * 6 + ($y + $dy)];
                if (
                    $target !== '.'
                    && ctype_lower($target) !== ctype_lower($board[$position[0] * 6 + $position[1]])
                ) {
                    yield [$x + $dx, $y + $dy];
                }
            }
        }
    }
}

function evaluate_board($board) {
    $piece_values = [
        "p" => -100, "P" => 100,
        "n" => -300, "N" => 300,
        "r" => -500, "R" => 500,
        "q" => -900, "Q" => 900,
        "k" => -10000, "K" => 10000,
        "." => 0,
    ];

    $total_value = 0;
    foreach (str_split($board) as $piece) {
        $total_value += $piece_values[$piece];
    }

    return $total_value;
}

function make_move($board, $position, $move) {
    $board = str_split($board);
    $pos_idx = $position[0] * 6 + $position[1];
    $move_idx = $move[0] * 6 + $move[1];
    $piece = $board[$pos_idx];

    $board[$pos_idx] = ".";
    $board[$move_idx] = $piece;

    if ($piece === "P" && $move[0] === 5) {
        $board[$move_idx] = "Q";
    } elseif ($piece === "p" && $move[0] === 0) {
        $board[$move_idx] = "q";
    }

    return implode('', $board);
}

function get_moves($idx, $piece, $board) {
    $board = str_split($board);
    $x = floor($idx / 6);
    $y = $idx % 6;

    switch ($piece) {
        case "P":
        case "p":
            yield from get_pawn_moves([$x, $y], $board);
            break;
        case "R":
        case "r":
            yield from get_rook_moves([$x, $y], $board);
            break;
        case "N":
        case "n":
            yield from get_knight_moves([$x, $y], $board);
            break;
        case "Q":
        case "q":
            yield from get_queen_moves([$x, $y], $board);
            break;
        case "K":
        case "k":
            yield from get_king_moves([$x, $y], $board);
            break;
        default:
            return;
    }
}

function negamax($board, $depth, $alpha, $beta, $color) {
    if ($depth == 0 || strpos($board, "k") === false || strpos($board, "K") === false) {
        return [$board, $color * evaluate_board($board)];
    }

    $best_value = -HIGH_VALUE;
    $best_board = $board;

    $pieces = str_split($board);

    foreach ($pieces as $idx => $piece) {
        if (($color == 1 && ctype_upper($piece)) || ($color == -1 && ctype_lower($piece))) {
            foreach (get_moves($idx, $piece, $board) as $move) {
                $new_board = make_move($board, [floor($idx / 6), $idx % 6], $move);
                list(, $move_value) = negamax($new_board, $depth - 1, -$beta, -$alpha, -$color);
                $move_value = -$move_value;

                if ($move_value > $best_value) {
                    $best_value = $move_value;
                    $best_board = $new_board;
                }

                $alpha = max($alpha, $best_value);

                if ($alpha >= $beta) {
                    break;
                }
            }
        }
        if ($alpha >= $beta) {
            break;
        }
    }

    return [$best_board, $best_value];
}

if ($_SERVER['argc'] > 2) {
    list(, $inputBoard, $color) = $_SERVER['argv'];

    list($board, ) = negamax(
        $inputBoard,
        SEARCH_DEPTH,
        -HIGH_VALUE,
        HIGH_VALUE,
        $color == "w" ? 1 : -1
    );

    echo "$board " . ($color == "w" ? "b" : "w");
}

?>

#!/usr/bin/env php
<?php

define('HIGH_VALUE', 100000);
define('SEARCH_DEPTH', 6);
define('EMPTY_SQUARE', 0);
define('wP', 1);
define('bP', -1);
define('wN', 2);
define('bN', -2);
define('wR', 3);
define('bR', -3);
define('wQ', 4);
define('bQ', -4);
define('wK', 5);
define('bK', -5);

function evaluate_board($board) {
    $piece_values = [
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
    ];

    $total_value = 0;
    foreach ($board as $piece) {
        $total_value += $piece_values[$piece + 5];
    }

    return $total_value;
}

function offset_moves($position, $board, $offsets) {
    foreach ($offsets as [$dx, $dy]) {
        $nx = $position[0] + $dx;
        $ny = $position[1] + $dy;
        if ($nx >= 0 && $nx < 6 && $ny >= 0 && $ny < 6) {
            $target = $board[$nx * 6 + $ny];
            if ($target * $board[$position[0] * 6 + $position[1]] <= 0) {
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
                if ($target === EMPTY_SQUARE) {
                    yield [$nx, $ny];
                    continue;
                }
                if ($target * $board[$position[0] * 6 + $position[1]] < 0) {
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
    $dx = $board[$position[0] * 6 + $position[1]] < 0 ? 1 : -1;

    if ($x + $dx >= 0 && $x + $dx < 6) {
        if ($board[($x + $dx) * 6 + $y] === EMPTY_SQUARE) {
            yield [$x + $dx, $y];
        }
        foreach ([-1, 1] as $dy) {
            if ($y + $dy >= 0 && $y + $dy < 6) {
                $target = $board[($x + $dx) * 6 + ($y + $dy)];
                if ($target * $board[$position[0] * 6 + $position[1]] < 0) {
                    yield [$x + $dx, $y + $dy];
                }
            }
        }
    }
}

function make_move($board, $position, $move) {
    $new_board = $board;
    $pos_idx = $position[0] * 6 + $position[1];
    $move_idx = $move[0] * 6 + $move[1];
    $piece = $new_board[$pos_idx];

    $new_board[$pos_idx] = EMPTY_SQUARE;
    $new_board[$move_idx] = $piece;

    if ($piece === wP && $move[0] === 5) {
        $new_board[$move_idx] = wQ;
    } elseif ($piece === bP && $move[0] === 0) {
        $new_board[$move_idx] = bQ;
    }

    return $new_board;
}

function get_moves($idx, $piece, $board) {
    $x = floor($idx / 6);
    $y = $idx % 6;

    switch ($piece) {
        case wP:
        case bP:
            yield from get_pawn_moves([$x, $y], $board);
            break;
        case wR:
        case bR:
            yield from get_rook_moves([$x, $y], $board);
            break;
        case wN:
        case bN:
            yield from get_knight_moves([$x, $y], $board);
            break;
        case wQ:
        case bQ:
            yield from get_queen_moves([$x, $y], $board);
            break;
        case wK:
        case bK:
            yield from get_king_moves([$x, $y], $board);
            break;
        default:
            return;
    }
}

function negamax($board, $depth, $alpha, $beta, $color) {
    if ($depth == 0 || in_array(wK, $board) === false || in_array(bK, $board) === false) {
        return [$board, $color * evaluate_board($board)];
    }

    $best_value = -HIGH_VALUE;
    $best_board = $board;

    foreach ($board as $idx => $piece) {
        if (($color == 1 && $piece > 0) || ($color == -1 && $piece < 0)) {
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

$char_to_int_map = [
    "." => EMPTY_SQUARE,
    "P" => wP,
    "p" => bP,
    "R" => wR,
    "r" => bR,
    "N" => wN,
    "n" => bN,
    "Q" => wQ,
    "q" => bQ,
    "K" => wK,
    "k" => bK,
];

function string_to_int_board($board) {
    global $char_to_int_map;
    $intBoard = [];
    for ($i = 0; $i < strlen($board); $i++) {
        $intBoard[] = $char_to_int_map[$board[$i]];
    }
    return $intBoard;
}

function int_to_string_board($intBoard) {
    global $char_to_int_map;
    $board = "";
    $int_to_char_map = array_flip($char_to_int_map);
    foreach ($intBoard as $piece) {
        $board .= $int_to_char_map[$piece];
    }
    return $board;
}


if ($_SERVER['argc'] > 2) {
    list(, $inputBoard, $color) = $_SERVER['argv'];

    list($board, ) = negamax(
        string_to_int_board($inputBoard),
        SEARCH_DEPTH,
        -HIGH_VALUE,
        HIGH_VALUE,
        $color == "w" ? 1 : -1
    );

    echo int_to_string_board($board). " " . ($color == "w" ? "b" : "w");
}

?>

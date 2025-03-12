const HIGH_VALUE: i32 = 100000;
const SEARCH_DEPTH: i32 = 6;

#[derive(Copy, Clone, PartialEq)]
enum Piece {
    Empty = 0,
    WP = 1,
    BP = -1,
    WN = 2,
    BN = -2,
    WR = 3,
    BR = -3,
    WQ = 4,
    BQ = -4,
    WK = 5,
    BK = -5,
}

use Piece::*;

fn evaluate_board(board: &[Piece]) -> i32 {
    board.iter().map(|&piece| match piece {
        BK => -10000,
        BQ => -900,
        BR => -500,
        BN => -300,
        BP => -100,
        Empty => 0,
        WP => 100,
        WN => 300,
        WR => 500,
        WQ => 900,
        WK => 10000,
    }).sum()
}

fn offset_moves(position: (isize, isize), board: &[Piece], offsets: &[(isize, isize)]) -> Vec<(isize, isize)> {
    offsets.iter().filter_map(|&(dx, dy)| {
        let nx = if dx < 0 { position.0.checked_sub(dx.abs()) } else { position.0.checked_add(dx) };
        let ny = if dy < 0 { position.1.checked_sub(dy.abs()) } else { position.1.checked_add(dy) };
        if let (Some(nx), Some(ny)) = (nx, ny) {
            if nx >= 0 && ny >= 0 && nx < 6 && ny < 6 && board[(position.0 * 6 + position.1) as usize] as isize * board[(nx * 6 + ny) as usize] as isize <= 0 {
                Some((nx, ny))
            } else {
                None
            }
        } else {
            None
        }
    }).collect()
}

fn get_knight_moves(position: (isize, isize), board: &[Piece]) -> Vec<(isize, isize)> {
    let offsets = [(2, 1), (1, 2), (-2, 1), (-1, 2), (2, -1), (1, -2), (-2, -1), (-1, -2)];
    offset_moves(position, board, &offsets)
}

fn get_king_moves(position: (isize, isize), board: &[Piece]) -> Vec<(isize, isize)> {
    let offsets = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)];
    offset_moves(position, board, &offsets)
}

fn vector_moves(position: (isize, isize), board: &[Piece], vectors: &[(isize, isize)]) -> Vec<(isize, isize)> {
    let mut moves = Vec::new();
    for &(dx, dy) in vectors.iter() {
        let mut nx = position.0;
        let mut ny = position.1;

        loop {
            nx += dx;
            ny += dy;

            if (0..6).contains(&nx) && (0..6).contains(&ny) {
                let target = board[(nx * 6 + ny) as usize];
                if target == Empty {
                    moves.push((nx, ny));
                    continue;
                }
                if (target as i32 * board[(position.0 * 6 + position.1) as usize] as i32) < 0 {
                    moves.push((nx, ny));
                }
            }
            break;
        }
    }
    moves
}

fn get_rook_moves(position: (isize, isize), board: &[Piece]) -> Vec<(isize, isize)> {
    let vectors = [(0, 1), (1, 0), (0, -1), (-1, 0)];
    vector_moves(position, board, &vectors)
}

fn get_queen_moves(position: (isize, isize), board: &[Piece]) -> Vec<(isize, isize)> {
    let mut moves = get_rook_moves(position, board);
    let diagonal_vectors = [(1, 1), (1, -1), (-1, 1), (-1, -1)];
    moves.extend(vector_moves(position, board, &diagonal_vectors));
    moves
}

fn get_pawn_moves(position: (isize, isize), board: &[Piece]) -> Vec<(isize, isize)> {
    let mut moves = Vec::new();
    let x = position.0;
    let y = position.1;
    let dx = if board[(position.0 * 6 + position.1) as usize] == BP { 1 } else { -1 };

    if x + dx >= 0 && x + dx < 6 {
        if board[((x + dx) * 6 + y) as usize] == Empty {
            moves.push((x + dx, y));
        }

        for &dy in [-1, 1].iter() {
            if y + dy >= 0 && y + dy < 6 {
                let target = board[((x + dx) * 6 + (y + dy)) as usize];
                if (target as i32 * board[(position.0 * 6 + position.1) as usize] as i32) < 0 {
                    moves.push((x + dx, y + dy));
                }
            }
        }
    }
    moves
}

fn get_moves(idx: isize, piece: Piece, board: &[Piece]) -> Vec<(isize, isize)> {
    let x = idx / 6;
    let y = idx % 6;
    
    match piece {
        WP | BP => get_pawn_moves((x, y), board),
        WR | BR => get_rook_moves((x, y), board),
        WN | BN => get_knight_moves((x, y), board),
        WQ | BQ => get_queen_moves((x, y), board),
        WK | BK => get_king_moves((x, y), board),
        _ => vec![]
    }
}

fn make_move(board: &[Piece], position: (isize, isize), move_to: (isize, isize)) -> Vec<Piece> {
    let mut new_board = board.to_vec();
    let pos_idx = (position.0 * 6 + position.1) as usize;
    let move_idx = (move_to.0 * 6 + move_to.1) as usize;
    let piece = new_board[pos_idx];

    new_board[pos_idx] = Empty;
    new_board[move_idx] = piece;

    if piece == WP && move_to.0 == 5 {
        new_board[move_idx] = WQ;
    } else if piece == BP && move_to.0 == 0 {
        new_board[move_idx] = BQ;
    }

    new_board
}

fn negamax(board: &[Piece], depth: i32, mut alpha: i32, beta: i32, color: i32) -> (Vec<Piece>, i32) {
    if depth == 0 || !board.contains(&WK) || !board.contains(&BK) {
        return (board.to_vec(), color * evaluate_board(board));
    }

    let mut best_value = -HIGH_VALUE;
    let mut best_board = board.to_vec();

    for (idx, &piece) in board.iter().enumerate() {
        if (color == 1 && (piece as i32) > 0) || (color == -1 && (piece as i32) < 0) {
            for move_to in get_moves(idx as isize, piece, board) {
                let new_board = make_move(board, ((idx / 6) as isize, (idx % 6) as isize), move_to);
                let (_, move_value) = negamax(&new_board, depth - 1, -beta, -alpha, -color);
                let move_value = -move_value;
                if move_value > best_value {
                    best_value = move_value;
                    best_board = new_board;
                }
                alpha = alpha.max(best_value);
                if alpha >= beta {
                    break;
                }
            }
            if alpha >= beta {
                break;
            }
        }
    }

    (best_board, best_value)
}


fn string_to_int_board(s: &str) -> [Piece; 36] {
    let mut board = [Empty; 36];
    for (idx, ch) in s.chars().enumerate() {
        board[idx] = match ch {
            'P' => WP,
            'p' => BP,
            'R' => WR,
            'r' => BR,
            'N' => WN,
            'n' => BN,
            'Q' => WQ,
            'q' => BQ,
            'K' => WK,
            'k' => BK,
            _ => Empty,
        };
    }
    board
}

fn int_to_string_board(board: &[Piece]) -> String {
    board.iter().map(|&piece| match piece {
        WP => 'P',
        BP => 'p',
        WR => 'R',
        BR => 'r',
        WN => 'N',
        BN => 'n',
        WQ => 'Q',
        BQ => 'q',
        WK => 'K',
        BK => 'k',
        _ => '.',
    }).collect()
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let initial_board = string_to_int_board(&args[1]);
    let color = if args[2] == "w" { 1 } else { -1 };

    let (final_board, _) = negamax(&initial_board, SEARCH_DEPTH, -HIGH_VALUE, HIGH_VALUE, color);
    println!("{} {}", int_to_string_board(&final_board), if color == 1 { "b" } else { "w" });
}

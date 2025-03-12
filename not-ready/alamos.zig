const std = @import("std");

const HIGH_VALUE = 100000;
const SEARCH_DEPTH = 6;

const EMPTY = 0;
const wP = 1;
const bP = -1;
const wN = 2;
const bN = -2;
const wR = 3;
const bR = -3;
const wQ = 4;
const bQ = -4;
const wK = 5;
const bK = -5;

// const PieceValues = []const i32{
//     -10000,
//     -900,
//     -500,
//     -300,
//     -100,
//     0,
//     100,
//     300,
//     500,
//     900,
//     10000,
// };
//
// const IntToChar = [11]i32{
//     "k", // bK
//     "q", // bQ
//     "r", // bR
//     "n", // bN
//     "p", // bP
//     ".", // EMPTY
//     "P", // wP
//     "N", // wN
//     "R", // wR
//     "Q", // wQ
//     "K", // wK
// };

fn charToInt(c: u8) i8 {
    if (c == "P"[0]) {
        return wP;
    }
    if (c == "p"[0]) {
        return bP;
    }
    if (c == "R"[0]) {
        return wR;
    }
    if (c == "r"[0]) {
        return bR;
    }
    if (c == "Q"[0]) {
        return wQ;
    }
    if (c == "q"[0]) {
        return bQ;
    }
    if (c == "N"[0]) {
        return wN;
    }
    if (c == "n"[0]) {
        return bN;
    }
    if (c == "K"[0]) {
        return wK;
    }
    if (c == "k"[0]) {
        return bK;
    }
    return EMPTY;
}

// const CharToIntMap = std.ComptimeStringMap(i32, .{
//     .{ ".", EMPTY },
//     .{ "P", wP },
//     .{ "p", bP },
//     .{ "R", wR },
//     .{ "r", bR },
//     .{ "N", wN },
//     .{ "n", bN },
//     .{ "Q", wQ },
//     .{ "q", bQ },
//     .{ "K", wK },
//     .{ "k", bK },
// });

// fn evaluateBoard(board: []const i32) i32 {
//     var sum: i32 = 0;
//     for (board) |piece| {
//         sum += PieceValues[piece + 5];
//     }
//     return sum;
// }
//
// fn offsetMoves(position: [2]i32, board: []const i32, offsets: []const [2]i32) [][2]i32 {
//     var moves = std.ArrayList([2]i32).init(std.heap.c_allocator);
//     defer moves.deinit();
//
//     for (offsets) |offset| {
//         const nx = position[0] + offset[0];
//         const ny = position[1] + offset[1];
//         if (nx >= 0 and nx < 6 and ny >= 0 and ny < 6) {
//             const target = board[@intCast(nx * 6 + ny)];
//             const piece = board[@intCast(position[0] * 6 + position[1])];
//             if (target * piece <= 0) {
//                 moves.append(.{ nx, ny }) catch unreachable;
//             }
//         }
//     }
//     return moves.toOwnedSlice();
// }
//
// fn getKnightMoves(position: [2]i32, board: []const i32) [][2]i32 {
//     const offsets = [_][2]i32{
//         .{ 2, 1 },  .{ 1, 2 },  .{ -2, 1 },  .{ -1, 2 },
//         .{ 2, -1 }, .{ 1, -2 }, .{ -2, -1 }, .{ -1, -2 },
//     };
//     return offsetMoves(position, board, &offsets);
// }
//
// fn getKingMoves(position: [2]i32, board: []const i32) [][2]i32 {
//     const offsets = [_][2]i32{
//         .{ 1, 0 }, .{ 0, 1 },  .{ -1, 0 }, .{ 0, -1 },
//         .{ 1, 1 }, .{ 1, -1 }, .{ -1, 1 }, .{ -1, -1 },
//     };
//     return offsetMoves(position, board, &offsets);
// }
//
// fn vectorMoves(position: [2]i32, board: []const i32, vectors: []const [2]i32) [][2]i32 {
//     var moves = std.ArrayList([2]i32).init(std.heap.c_allocator);
//     defer moves.deinit();
//
//     for (vectors) |vector| {
//         var nx = position[0];
//         var ny = position[1];
//         while (true) {
//             nx += vector[0];
//             ny += vector[1];
//             if (nx >= 0 and nx < 6 and ny >= 0 and ny < 6) {
//                 const target = board[@intCast(nx * 6 + ny)];
//                 if (target == EMPTY) {
//                     moves.append(.{ nx, ny }) catch unreachable;
//                     continue;
//                 }
//                 const piece = board[@intCast(position[0] * 6 + position[1])];
//                 if (target * piece < 0) {
//                     moves.append(.{ nx, ny }) catch unreachable;
//                 }
//             }
//             break;
//         }
//     }
//     return moves.toOwnedSlice();
// }
//
// fn getRookMoves(position: [2]i32, board: []const i32) [][2]i32 {
//     const vectors = [_][2]i32{ .{ 0, 1 }, .{ 1, 0 }, .{ 0, -1 }, .{ -1, 0 } };
//     return vectorMoves(position, board, &vectors);
// }
//
// fn getQueenMoves(position: [2]i32, board: []const i32) [][2]i32 {
//     const vectors = [_][2]i32{ .{ 1, 1 }, .{ 1, -1 }, .{ -1, 1 }, .{ -1, -1 } };
//     var moves = std.ArrayList([2]i32).init(std.heap.c_allocator);
//     defer moves.deinit();
//
//     moves.appendSlice(vectorMoves(position, board, &vectors)) catch unreachable;
//     moves.appendSlice(getRookMoves(position, board)) catch unreachable;
//     return moves.toOwnedSlice();
// }
//
// fn getPawnMoves(position: [2]i32, board: []const i32) [][2]i32 {
//     var moves = std.ArrayList([2]i32).init(std.heap.c_allocator);
//     defer moves.deinit();
//
//     const x = position[0];
//     const y = position[1];
//     const dx = if (board[@as(usize, @intCast(x * 6 + y))] < 0) 1 else -1; // Explicit type for @intCast
//
//     if (x + dx >= 0 and x + dx < 6) {
//         if (board[@as(usize, @intCast((x + dx) * 6 + y))] == EMPTY) { // Explicit type for @intCast
//             moves.append(.{ x + dx, y }) catch unreachable;
//         }
//         const dyValues = [_]i32{ -1, 1 };
//         for (dyValues) |dy| {
//             if (y + dy >= 0 and y + dy < 6) {
//                 const target = board[@as(usize, @intCast((x + dx) * 6 + (y + dy)))]; // Explicit type for @intCast
//                 const piece = board[@as(usize, @intCast(x * 6 + y))]; // Explicit type for @intCast
//                 if (target * piece < 0) {
//                     moves.append(.{ x + dx, y + dy }) catch unreachable;
//                 }
//             }
//         }
//     }
//     return moves.toOwnedSlice();
// }
//
// fn makeMove(board: []const i32, position: [2]i32, move: [2]i32) []i32 {
//     var newBoard = std.ArrayList(i32).init(std.heap.c_allocator);
//     defer newBoard.deinit();
//
//     newBoard.appendSlice(board) catch unreachable;
//
//     const posIdx = @as(usize, @intCast(position[0] * 6 + position[1])); // Explicit type for @intCast
//     const moveIdx = @as(usize, @intCast(move[0] * 6 + move[1])); // Explicit type for @intCast
//     const piece = newBoard.items[posIdx];
//
//     newBoard.items[posIdx] = EMPTY;
//     newBoard.items[moveIdx] = piece;
//
//     if (piece == wP and move[0] == 5) {
//         newBoard.items[moveIdx] = wQ;
//     } else if (piece == bP and move[0] == 0) {
//         newBoard.items[moveIdx] = bQ;
//     }
//
//     return newBoard.toOwnedSlice();
// }
//
// fn getMoves(idx: usize, piece: i32, board: []const i32) [][2]i32 {
//     const x = @divTrunc(idx, 6);
//     const y = @mod(idx, 6);
//
//     switch (piece) {
//         wP, bP => return getPawnMoves(.{ x, y }, board),
//         wR, bR => return getRookMoves(.{ x, y }, board),
//         wN, bN => return getKnightMoves(.{ x, y }, board),
//         wQ, bQ => return getQueenMoves(.{ x, y }, board),
//         wK, bK => return getKingMoves(.{ x, y }, board),
//         else => return &[_][2]i32{},
//     }
// }

// fn negamax(board: []const i32, depth: i32, alpha: i32, beta: i32, color: i32) struct { []i32, i32 } {
//     if (depth == 0 or !std.mem.containsAtLeast(i32, board, 1, &[_]i32{wK}) or !std.mem.containsAtLeast(i32, board, 1, &[_]i32{bK})) {
//         return .{ board, color * evaluateBoard(board) };
//     }
//
//     var bestValue: i32 = -HIGH_VALUE;
//     var bestBoard = board;
//
//     for (board, 0..) |piece, idx| {
//         if ((color == 1 and piece > 0) or (color == -1 and piece < 0)) {
//             const moves = getMoves(idx, piece, board);
//             for (moves) |move| {
//                 const newBoard = makeMove(board, .{ @divTrunc(idx, 6), @mod(idx, 6) }, move);
//                 const result = negamax(newBoard, depth - 1, -beta, -alpha, -color);
//                 const moveValue = -result[1];
//                 if (moveValue > bestValue) {
//                     bestValue = moveValue;
//                     bestBoard = newBoard;
//                 }
//                 const newAlpha = std.math.max(alpha, bestValue);
//                 if (newAlpha >= beta) {
//                     break;
//                 }
//             }
//             if (alpha >= beta) {
//                 break;
//             }
//         }
//     }
//
//     return .{ bestBoard, bestValue };
// }

// fn stringToIntBoard(board: []const u8) []i32 {
//     var intBoard = std.ArrayList(i32).init(std.heap.c_allocator);
//     defer intBoard.deinit();
//
//     for (board) |char| {
//         intBoard.append(CharToIntMap.get(&[_]u8{char}) orelse EMPTY) catch unreachable;
//     }
//
//     return intBoard.toOwnedSlice();
// }

// const IntToCharMap = [11]u8{
//     .{ EMPTY, '.' },
//     .{ wP, 'P' },
//     .{ bP, 'p' },
//     .{ wR, 'R' },
//     .{ bR, 'r' },
//     .{ wN, 'N' },
//     .{ bN, 'n' },
//     .{ wQ, 'Q' },
//     .{ bQ, 'q' },
//     .{ wK, 'K' },
//     .{ bK, 'k' },
// });

// fn intToStringBoard(intBoard: []const i32) []u8 {
//     var stringBoard = std.ArrayList(u8).init(std.heap.c_allocator);
//     defer stringBoard.deinit();
//
//     for (intBoard) |piece| {
//         stringBoard.append(IntToCharMap.get(&[_]i32{piece}) orelse '.') catch unreachable;
//     }
//
//     return stringBoard.toOwnedSlice();
// }

pub fn main() void {
    std.debug.print("Hello, {s}!\n", .{"World"});
    std.debug.print("There are {d} args:\n", .{std.os.argv.len});

    if (std.os.argv.len < 3) {
        std.debug.print("Usage: {s} <board> <color>\n", .{std.mem.sliceTo(std.os.argv[0], 0)});
        return;
    }

    for (std.os.argv) |arg| {
        std.debug.print("  {s}\n", .{arg});
    }

    var board: [36]i8 = undefined;

    for (std.mem.sliceTo(std.os.argv[1], 0), 0..) |c, i| {
        std.debug.print("{d}: {d}\n", .{ i, c });
        board[i] = charToInt(c);
    }

    var color: i8 = 1;
    if (std.mem.eql(u8, std.mem.sliceTo(std.os.argv[2], 0), "b")) {
        color = -1;
    }
    std.debug.print("color: {d}\n", .{color});

    // const args = std.process.args();
    // for (args, 0..) |arg, index| {
    //     std.debug.print("Argument {}: {}\n", .{ index, arg });
    // }
    // const args = try std.process.argsAlloc(std.heap.page_allocator);
    // // defer std.process.argsFree(std.heap.c_allocator, args);

    // if (args.len < 3) {
    //     std.debug.print("Usage: {} <board> <color>\n", .{args[0]});
    //     return;
    // }

    // std.debug.print("{s} {s}\n", .{ args[1], args[2] });

    // const board = stringToIntBoard(args[1]);
    // const color = if (std.mem.eql(u8, args[2], "w")) 1 else -1;

    // const result = negamax(board, SEARCH_DEPTH, -HIGH_VALUE, HIGH_VALUE, color);
    // const bestBoard = result[0];

    // const outputBoard = intToStringBoard(bestBoard);
    // const outputColor = if (std.mem.eql(u8, args[2], "w")) "b" else "w";

    // std.debug.print("{s} {s}\n", .{ outputBoard, outputColor });
}

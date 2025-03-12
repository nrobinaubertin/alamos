#!/usr/bin/lua

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

function table_contains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function evaluate_board(board)
  local piece_values = {-10000, -900, -500, -300, -100, 0, 100, 300, 500, 900, 10000}
  local sum = 0
  for _, piece in ipairs(board) do
    sum = sum + piece_values[piece + 6]
  end
  return sum
end

function offset_moves(position, board, offsets)
  local results = {}
  for _, offset in ipairs(offsets) do
    local dx, dy = offset[1], offset[2]
    local nx, ny = position[1] + dx, position[2] + dy
    if nx >= 1 and nx <= 6 and ny >= 1 and ny <= 6 then
      local target = board[(nx - 1) * 6 + ny]
      if target * board[(position[1] - 1) * 6 + position[2]] <= 0 then
        table.insert(results, {nx, ny})
      end
    end
  end
  return results
end

function get_knight_moves(position, board)
  local offsets = {{2, 1}, {1, 2}, {-2, 1}, {-1, 2}, {2, -1}, {1, -2}, {-2, -1}, {-1, -2}}
  return offset_moves(position, board, offsets)
end

function get_king_moves(position, board)
  local offsets = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}, {1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
  return offset_moves(position, board, offsets)
end

function vector_moves(position, board, vectors)
  local results = {}
  for _, vector in ipairs(vectors) do
    local dx, dy = vector[1], vector[2]
    local nx, ny = position[1], position[2]
    while true do
      nx, ny = nx + dx, ny + dy
      if nx >= 1 and nx <= 6 and ny >= 1 and ny <= 6 then
        local target = board[(nx - 1) * 6 + ny]
        if target == EMPTY then
          table.insert(results, {nx, ny})
        else
          if target * board[(position[1] - 1) * 6 + position[2]] < 0 then
            table.insert(results, {nx, ny})
          end
          break
        end
      else
        break
      end
    end
  end
  return results
end

function get_rook_moves(position, board)
  local vectors = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}}
  return vector_moves(position, board, vectors)
end

function get_queen_moves(position, board)
  local results = {}
  local vectors = {{1, 1}, {1, -1}, {-1, 1}, {-1, -1}}
  for _, move in ipairs(vector_moves(position, board, vectors)) do
    table.insert(results, move)
  end
  for _, move in ipairs(get_rook_moves(position, board)) do
    table.insert(results, move)
  end
  return results
end

function get_pawn_moves(position, board)
  local x, y = position[1], position[2]
  local dx = board[(x - 1) * 6 + y] < 0 and 1 or -1
  local results = {}

  if x + dx >= 1 and x + dx <= 6 then
    if board[(x + dx - 1) * 6 + y] == EMPTY then
      table.insert(results, {x + dx, y})
    end
    for _, dy in ipairs({-1, 1}) do
      if y + dy >= 1 and y + dy <= 6 then
        local target = board[(x + dx - 1) * 6 + y + dy]
        if target * board[(x - 1) * 6 + y] < 0 then
          table.insert(results, {x + dx, y + dy})
        end
      end
    end
  end
  return results
end

function make_move(board, position, move)
  local new_board = {}
  for i, v in ipairs(board) do
    new_board[i] = v
  end
  local pos_idx = (position[1] - 1) * 6 + position[2]
  local move_idx = (move[1] - 1) * 6 + move[2]
  local piece = new_board[pos_idx]

  new_board[pos_idx] = EMPTY
  new_board[move_idx] = piece

  if piece == wP and move[1] == 5 then
    new_board[move_idx] = wQ
  elseif piece == bP and move[1] == 0 then
    new_board[move_idx] = bQ
  end

  return new_board
end

function get_moves(idx, piece, board)
  local x = math.floor((idx - 1) / 6) + 1
  local y = (idx - 1) % 6 + 1
  local moves = {}

  local piece_sets = {
    {wP, bP},
    {wR, bR},
    {wN, bN},
    {wQ, bQ},
    {wK, bK}
  }

  local funcs = {
    get_pawn_moves,
    get_rook_moves,
    get_knight_moves,
    get_queen_moves,
    get_king_moves
  }

  for i, set in ipairs(piece_sets) do
    for _, p in ipairs(set) do
      if piece == p then
        for _, move in ipairs(funcs[i]({x, y}, board)) do
          table.insert(moves, move)
        end
        return moves
      end
    end
  end

  return moves
end

function negamax(board, depth, alpha, beta, color)
  if depth == 0 or not table_contains(board, wK) or not table_contains(board, bK) then
    return board, color * evaluate_board(board)
  end

  local best_value = -HIGH_VALUE
  local best_board = board

  for idx, piece in ipairs(board) do
    if (color == 1 and piece > 0) or (color == -1 and piece < 0) then
      for _, move in ipairs(get_moves(idx, piece, board)) do
        local new_board = make_move(board, {math.floor((idx - 1) / 6) + 1, (idx - 1) % 6 + 1}, move)
        local _, move_value = negamax(new_board, depth - 1, -beta, -alpha, -color)
        move_value = -move_value
        if move_value > best_value then
          best_value = move_value
          best_board = new_board
        end
        alpha = math.max(alpha, best_value)
        if alpha >= beta then
          break
        end
      end
      if alpha >= beta then
        break
      end
    end
  end

  return best_board, best_value
end

char_to_int_map = {
  ["."] = EMPTY,
  ["P"] = wP,
  ["p"] = bP,
  ["R"] = wR,
  ["r"] = bR,
  ["N"] = wN,
  ["n"] = bN,
  ["Q"] = wQ,
  ["q"] = bQ,
  ["K"] = wK,
  ["k"] = bK
}

function string_to_int_board(board_string)
  local board = {}
  for i = 1, #board_string do
    local c = board_string:sub(i,i)
    table.insert(board, char_to_int_map[c])
  end
  return board
end

function int_to_string_board(int_board)
  local board_string = ""
  for _, piece in ipairs(int_board) do
    for char, int_value in pairs(char_to_int_map) do
      if int_value == piece then
        board_string = board_string .. char
        break
      end
    end
  end
  return board_string
end

-- Main execution
local args = {...}

local board, _ = negamax(
  string_to_int_board(args[1]),
  SEARCH_DEPTH,
  -HIGH_VALUE,
  HIGH_VALUE,
  (args[2] == "w" and 1) or -1
)

print(int_to_string_board(board) .. " " .. ((args[2] == "w" and "b") or "w"))

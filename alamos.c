#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HIGH_VALUE 100000
#define SEARCH_DEPTH 6

typedef enum {
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
  BK = -5
} Piece;

typedef struct {
  Piece board[36];
  int value;
} NegamaxResult;

typedef struct {
  int x;
  int y;
} Position;

#define MAX_OFFSETS 16 // Max number of positions a piece can move to.

typedef struct {
  Position positions[MAX_OFFSETS];
  int count;
} PositionArray;

// Function signatures, needed because C requires forward declaration
int evaluate_board(Piece *board);
void string_to_int_board(const char *s, Piece *board);
void int_to_string_board(const Piece *board, char *s);
PositionArray offset_moves(Position pos, Piece board[36], Position offsets[],
                           int offset_count);
PositionArray vector_moves(Position pos, Piece board[36], Position offsets[],
                           int vector_count);
PositionArray get_knight_moves(Position pos, Piece board[36]);
PositionArray get_king_moves(Position pos, Piece board[36]);
PositionArray get_rook_moves(Position pos, Piece board[36]);
PositionArray get_queen_moves(Position pos, Piece board[36]);
PositionArray get_pawn_moves(Position pos, Piece board[36]);
PositionArray get_moves(int idx, Piece piece, Piece board[36]);
void make_move(Piece board[36], Position position, Position move_to,
               Piece new_board[36]);
NegamaxResult negamax(Piece board[36], int depth, int alpha, int beta,
                      int color);
bool contains(const Piece board[36], Piece piece);

int max(int a, int b) { return (a >= b) ? a : b; }

bool contains(const Piece board[36], Piece piece) {
  for (int i = 0; i < 36; i++) {
    if (board[i] == piece) {
      return true;
    }
  }
  return false;
}

int evaluate_board(Piece board[36]) {
  int total = 0;
  for (int i = 0; i < 36; i++) {
    switch (board[i]) {
    case BK:
      total -= 10000;
      break;
    case BQ:
      total -= 900;
      break;
    case BR:
      total -= 500;
      break;
    case BN:
      total -= 300;
      break;
    case BP:
      total -= 100;
      break;
    case Empty:
      break;
    case WP:
      total += 100;
      break;
    case WN:
      total += 300;
      break;
    case WR:
      total += 500;
      break;
    case WQ:
      total += 900;
      break;
    case WK:
      total += 10000;
      break;
    }
  }
  return total;
}

PositionArray offset_moves(Position pos, Piece board[36], Position offsets[],
                           int offset_count) {
  PositionArray result = {.count = 0};
  for (int i = 0; i < offset_count; i++) {
    int nx = pos.x + offsets[i].x;
    int ny = pos.y + offsets[i].y;

    if (nx >= 0 && nx < 6 && ny >= 0 && ny < 6 &&
        board[pos.x * 6 + pos.y] * board[nx * 6 + ny] <= 0) {
      result.positions[result.count].x = nx;
      result.positions[result.count].y = ny;
      result.count++;
    }
  }
  return result;
}

PositionArray get_knight_moves(Position pos, Piece board[36]) {
  Position offsets[8] = {{2, 1},  {1, 2},  {-2, 1},  {-1, 2},
                         {2, -1}, {1, -2}, {-2, -1}, {-1, -2}};
  return offset_moves(pos, board, offsets, 8);
}

PositionArray get_king_moves(Position pos, Piece board[36]) {
  Position offsets[8] = {{1, 0}, {0, 1},  {-1, 0}, {0, -1},
                         {1, 1}, {1, -1}, {-1, 1}, {-1, -1}};
  return offset_moves(pos, board, offsets, 8);
}

PositionArray vector_moves(Position pos, Piece board[36], Position vectors[],
                           int vector_count) {
  PositionArray result = {.count = 0};

  for (int i = 0; i < vector_count; i++) {
    int nx = pos.x;
    int ny = pos.y;

    while (1) {
      nx += vectors[i].x;
      ny += vectors[i].y;

      if (nx >= 0 && nx < 6 && ny >= 0 && ny < 6) {
        Piece target = board[nx * 6 + ny];
        if (target == Empty) {
          result.positions[result.count].x = nx;
          result.positions[result.count].y = ny;
          result.count++;
          continue;
        }
        if (target * board[pos.x * 6 + pos.y] < 0) {
          result.positions[result.count].x = nx;
          result.positions[result.count].y = ny;
          result.count++;
        }
      }
      break;
    }
  }
  return result;
}

PositionArray get_rook_moves(Position pos, Piece board[36]) {
  Position vectors[4] = {{0, 1}, {1, 0}, {0, -1}, {-1, 0}};
  return vector_moves(pos, board, vectors, 4);
}

PositionArray get_queen_moves(Position pos, Piece board[36]) {
  Position vectors[8] = {{0, 1}, {1, 0},  {0, -1}, {-1, 0},
                         {1, 1}, {1, -1}, {-1, 1}, {-1, -1}};
  return vector_moves(pos, board, vectors, 8);
}

PositionArray get_pawn_moves(Position pos, Piece board[36]) {
  PositionArray result = {.count = 0};
  int x = pos.x;
  int y = pos.y;
  int dx = (board[pos.x * 6 + pos.y] == BP) ? 1 : -1;

  if (x + dx >= 0 && x + dx < 6) {
    if (board[(x + dx) * 6 + y] == Empty) {
      result.positions[result.count].x = x + dx;
      result.positions[result.count].y = y;
      result.count++;
    }
    int dy_offsets[2] = {-1, 1};
    for (int i = 0; i < 2; i++) {
      int dy = dy_offsets[i];
      if (y + dy >= 0 && y + dy < 6) {
        Piece target = board[(x + dx) * 6 + (y + dy)];
        if (target * board[pos.x * 6 + pos.y] < 0) {
          result.positions[result.count].x = x + dx;
          result.positions[result.count].y = y + dy;
          result.count++;
        }
      }
    }
  }
  return result;
}

void make_move(Piece board[36], Position position, Position move_to,
               Piece new_board[36]) {
  int pos_idx = position.x * 6 + position.y;
  int move_idx = move_to.x * 6 + move_to.y;
  Piece piece = board[pos_idx];

  memcpy(new_board, board, sizeof(Piece) * 36);

  new_board[pos_idx] = Empty;
  new_board[move_idx] = piece;

  if (piece == WP && move_to.x == 5) {
    new_board[move_idx] = WQ;
  } else if (piece == BP && move_to.x == 0) {
    new_board[move_idx] = BQ;
  }
}

PositionArray get_moves(int idx, Piece piece, Piece board[36]) {
  int x = idx / 6;
  int y = idx % 6;
  Position pos = {x, y};

  switch (piece) {
  case WP:
  case BP:
    return get_pawn_moves(pos, board);
  case WR:
  case BR:
    return get_rook_moves(pos, board);
  case WN:
  case BN:
    return get_knight_moves(pos, board);
  case WQ:
  case BQ:
    return get_queen_moves(pos, board);
  case WK:
  case BK:
    return get_king_moves(pos, board);
  default:
    return (PositionArray){.count = 0};
  }
}

NegamaxResult negamax(Piece board[36], int depth, int alpha, int beta,
                      int color) {
  if (depth == 0 || !contains(board, WK) || !contains(board, BK)) {
    return (NegamaxResult){.value = color * evaluate_board(board)};
  }

  NegamaxResult best;
  best.value = -HIGH_VALUE;

  for (int idx = 0; idx < 36; idx++) {
    Piece piece = board[idx];
    if ((color == 1 && piece > 0) || (color == -1 && piece < 0)) {
      PositionArray moves = get_moves(idx, piece, board);
      for (int j = 0; j < moves.count; j++) {
        Piece new_board[36];
        make_move(board, (Position){idx / 6, idx % 6}, moves.positions[j],
                  new_board);
        NegamaxResult result =
            negamax(new_board, depth - 1, -beta, -alpha, -color);
        int move_value = -result.value;
        if (move_value > best.value) {
          best.value = move_value;
          memcpy(best.board, new_board, sizeof(Piece) * 36);
        }
        alpha = max(alpha, best.value);
        if (alpha >= beta) {
          break;
        }
      }
      if (alpha >= beta) {
        break;
      }
    }
  }

  return best;
}

void string_to_int_board(const char *str, Piece board[36]) {
  for (int i = 0; i < 36; i++) {
    switch (str[i]) {
    case 'P':
      board[i] = WP;
      break;
    case 'p':
      board[i] = BP;
      break;
    case 'N':
      board[i] = WN;
      break;
    case 'n':
      board[i] = BN;
      break;
    case 'R':
      board[i] = WR;
      break;
    case 'r':
      board[i] = BR;
      break;
    case 'Q':
      board[i] = WQ;
      break;
    case 'q':
      board[i] = BQ;
      break;
    case 'K':
      board[i] = WK;
      break;
    case 'k':
      board[i] = BK;
      break;
    default:
      board[i] = Empty;
      break;
    }
  }
}

void int_to_string_board(const Piece board[36], char str[37]) {
  for (int i = 0; i < 36; i++) {
    switch (board[i]) {
    case WP:
      str[i] = 'P';
      break;
    case BP:
      str[i] = 'p';
      break;
    case WN:
      str[i] = 'N';
      break;
    case BN:
      str[i] = 'n';
      break;
    case WR:
      str[i] = 'R';
      break;
    case BR:
      str[i] = 'r';
      break;
    case WQ:
      str[i] = 'Q';
      break;
    case BQ:
      str[i] = 'q';
      break;
    case WK:
      str[i] = 'K';
      break;
    case BK:
      str[i] = 'k';
      break;
    default:
      str[i] = '.';
      break;
    }
  }
  str[36] = '\0'; // Null terminate the string
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Not enough arguments provided\n");
    return 1;
  }

  Piece initial_board[36];
  string_to_int_board(argv[1], initial_board);

  int color = strcmp(argv[2], "w") == 0 ? 1 : -1;

  Piece final_board[36];
  int value;
  NegamaxResult res =
      negamax(initial_board, SEARCH_DEPTH, -HIGH_VALUE, HIGH_VALUE, color);

  char s[37];
  int_to_string_board(res.board, s);
  printf("%s %c\n", s, color == 1 ? 'b' : 'w');

  return 0;
}

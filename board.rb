load './pieces.rb'
#load 'colorize'
#require 'cursorable'
require 'byebug'

class Board
    attr_accessor :grid, :current_player

  def initialize(trigger = false)
    @grid = Array.new(8) { Array.new(8) { EmptySquare.new(:gray, nil, self) } }
    @current_player = :white
    setup(trigger)
  end

  def setup(trigger)
    if trigger
      populate_board
      initialize_moves
    end
  end

  def initialize_moves
    grid.each do |row|
      row.each do |piece|
        piece.get_moves
      end
    end
  end

  def swap_players!
    @current_player == :white ? @current_player = :black : @current_player = :white
  end

  def populate_board
    populate_pawns
    populate_bishops
    populate_knights
    populate_rooks
    populate_queens
    populate_kings
  end

  def populate_pawns
    (0...8).each do |cell|
      self[[1, cell]] = Pawn.new(:black, [1, cell], self)
      self[[6, cell]] = Pawn.new(:white, [6, cell], self)
    end
  end

  def populate_bishops
    self[[0, 2]] = Bishop.new(:black, [0, 2], self)
    self[[0, 5]] = Bishop.new(:black, [0, 5], self)
    self[[7, 2]] = Bishop.new(:white, [7, 2], self)
    self[[7, 5]] = Bishop.new(:white, [7, 5], self)
  end

  def populate_knights
    self[[0, 1]] = Knight.new(:black, [0, 1], self)
    self[[0, 6]] = Knight.new(:black, [0, 6], self)
    self[[7, 1]] = Knight.new(:white, [7, 1], self)
    self[[7, 6]] = Knight.new(:white, [7, 6], self)
  end

  def populate_rooks
    self[[0, 0]] = Rook.new(:black, [0, 0], self)
    self[[0, 7]] = Rook.new(:black, [0, 7], self)
    self[[7, 0]] = Rook.new(:white, [7, 0], self)
    self[[7, 7]] = Rook.new(:white, [7, 7], self)
  end

  def populate_queens
    self[[0, 3]] = Queen.new(:black, [0, 3], self)
    self[[7, 3]] = Queen.new(:white, [7, 3], self)
  end

  def populate_kings
    self[[0, 4]] = King.new(:black, [0, 4], self)
    self[[7, 4]] = King.new(:white, [7, 4], self)
  end

  def on_board?(pos)
    pos.all? { |pos| pos >= 0 && pos < 8 }
  end

  def occupied?(pos)
    !self[pos].is_a?(EmptySquare)
  end

  def [](pos)
    x, y = pos
    grid[x][y]
  end

  def []=(pos, value)
    x, y = pos
    grid[x][y] = value
  end

  def rows
    @grid
  end

  def will_be_in_check?(start_pos, destination, color)
    dupped_board = dup_board
    dupped_board.make_move(start_pos, destination)
    dupped_board.initialize_moves
    king_location = dupped_board.find_king(color) # this was the problem! previously, it was just "find_king(color)" which would find_king on the old board. we need to check it on the new board.
    dupped_board.grid.each do |row|
      row.each do |piece|
        return true if piece.color != color && piece.available_moves.include?(king_location)
      end
    end
    false
  end

  def currently_in_check?(color)
    king_location = find_king(color)
    grid.each do |row|
      row.each do |piece|
        return true if piece.color != color && piece.available_moves.include?(king_location)
      end
    end
    false
  end

  def checkmate?(color)
    grid.each do |row|
      row.each do |piece|
        if piece.color == color
          return false if piece.available_moves.any? do |move|
            !will_be_in_check?(piece.pos, move, color)
          end
        end
      end
    end
    true
  end

  def find_king(color)
    grid.each do |row|
      row.each do |piece|
        return piece.pos if piece.is_a?(King) && piece.color == color
      end
    end
  end

  def make_move(start_position, destination)
    self[destination] = self[start_position]
    self[destination].pos = destination
    self[start_position] = EmptySquare.new(:gray, start_position, self)
    initialize_moves
  end

  def pieces(board)
    pieces = []

    grid.each do |row|
      row.each do |piece|
        unless piece.is_a?(EmptySquare)
          dup_piece = piece.class.new(piece.color, piece.pos, board)
          pieces << dup_piece
        end
      end
    end

    pieces
  end

  def dup_board
    dup_board = Board.new
    dup_pieces = pieces(dup_board)
    dup_pieces.each do |piece|
      dup_board[piece.pos] = piece
    end
    dup_board
  end
end

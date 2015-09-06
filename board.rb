require './pieces'

class Board
  attr_accessor :grid, :current_player

  def initialize(trigger)
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
    grid.flatten.each { |tile| tile.get_moves if tile.is_piece?}
  end

  def swap_players!
    @current_player = @current_player == :white ? :black : :white
  end

  def populate_board
    (0..7).each do |v|
      (0..7).each do |h|
        pos = [v, h]
        if v <= 2 # black pieces
          self[pos] = Checker.new(:black, pos, self) if (v + h).odd?
        elsif v >= 5 # red pieces
          self[pos] = Checker.new(:white, pos, self) if (v + h).odd?
        end
      end
    end
  end

  def populate_pawns
  end

  def in_bounds?(pos)
    pos.all? { |pos| pos.between?(0,7) }
  end

  def occupied?(pos)
    !self[pos].is_a?(EmptySquare)
  end

  # def unoccupied?(pos)
  #
  # end

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

  def lost?
    pieces.none? { |piece| piece.color == @current_player }
  end

  def pieces
    grid.flatten.select { |tile| tile.is_piece? }
  end

  def make_move(from_pos, to_pos)
    base_pos = self[from_pos].valid_moves[to_pos]
    base_pos.nil? ? base_move!(from_pos, to_pos) : jump_move!(from_pos, to_pos)
  end

  def base_move!(from_pos, to_pos)
    self[to_pos] = self[from_pos]
    self[to_pos].pos = to_pos
    self[from_pos] = EmptySquare.new(:none, from_pos, self)
    initialize_moves
  end

  def jump_move!(from_pos, to_pos)
    base_pos = self[from_pos].valid_moves[to_pos]
    self[to_pos] = self[from_pos]
    self[to_pos].pos = to_pos
    self[base_pos] = empty_tile(base_pos)
    self[from_pos] = empty_tile(from_pos)
    initialize_moves
  end

  def empty_tile(pos)
    EmptySquare.new(:none, pos, self)
  end

  # def dup_board
  #   dup_board = Board.new
  #   dup_pieces = pieces(dup_board)
  #   dup_pieces.each do |piece|
  #     dup_board[piece.pos] = piece
  #   end
  #   dup_board
  # end
end

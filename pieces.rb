require 'byebug'
class Piece
  attr_reader :face, :color, :valid_moves
  attr_accessor :selected, :pos, :board
  def initialize(color, pos, board)
    @board = board
    @color = color
    @face = ""
    @pos = pos
    @selected = false
    @valid_moves = {}
  end

  def is_piece?
    !is_a?(EmptySquare)
  end

  def enemy?(piece)
    return true if (@color == :white && piece.color == :black) ||
      (@color == :black && piece.color == :white)
    false
  end
end

class EmptySquare < Piece
  def initialize(color, pos, board)
    super(color, pos, board)
    color == :black ? @face = "  " : @face = "  "
  end

  def get_moves
    @valid_moves = []
  end

  def cannot_jump?
    true
  end
end


class Checker < Piece

  def initialize(color, pos, board)
    super(color, pos, board)
    @face = color == :black ? "⚫ " : "⚪ "
  end

  # BASE_DIFFS = self.color == :white ? [[-1, -1], [-1, 1]] : [[1, 1], [1, -1]]
  # JUMP_DIFFS = self.color == :white ? [[-2, -2], [-2, 2]] : [[2, 2], [2, -2]]

  def get_moves
    reset_moves
    jump_moves
    base_moves if @valid_moves.empty?
  end

  def reset_moves
    @valid_moves, @jump_moves = {}, {}
  end

  def base_diffs
    color == :white ? [[-1, -1], [-1, 1]] : [[1, -1], [1, 1]]
  end

  def base_moves
    base_diffs.each do |diff|
      pos = [@pos[0] + diff[0], @pos[1] + diff[1]]
      @valid_moves[pos] = nil if pos.all? { |dim| dim.between?(0, 7) }
    end
    @valid_moves.select! { |move, _| !board.occupied?(move) }
  end

  def jump_diffs
    color == :white ? [[-2, -2], [-2, 2]] : [[2, -2], [2, 2]]
  end

  def jump_moves
    x, y = @pos[0], @pos[1]
    (0..1).each do |idx|
      # byebug if color == :white
      base_move = [x + base_diffs[idx][0], y + base_diffs[idx][1]]
      next unless base_move.all? { |dim| dim.between?(0, 7) }
      jump_move = [x + jump_diffs[idx][0], y + jump_diffs[idx][1]]
      next unless jump_move.all? { |dim| dim.between?(0, 7) }
      if enemy?(board[base_move]) && !board.occupied?(jump_move)
        @valid_moves[jump_move] = base_move
      end
    end
    true
  end

  def cannot_jump?
    @valid_moves.values.all?(&:nil?)
  end

  def can_jump?
    !cannot_jump?
  end
end

# # This class was designed as if an ordinary Checker can move backward. But
# # that's the case only if that Checker is a king. After I write the ordinary
# # Checker class, uncomment the below code and name it KingChecker
# #
# class Checker < Piece
#   BASE_DIFFS = [[-1, -1], [-1, 1], [1, 1], [1, -1]]
#   JUMP_DIFFS = [[-2, -2], [-2, 2], [2, 2], [2, -2]]
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     @face = color == :black ? "⚫ " : "⚪ "
#   end
#
#   def get_moves
#     reset_moves
#     base_moves
#     jump_moves
#
#   end
#
#   def reset_moves
#     @valid_moves, @jump_moves = {}, {}
#   end
#
#   def base_moves
#     BASE_DIFFS.each do |diff|
#       pos = [@pos[0] + diff[0], @pos[1] + diff[1]]
#       @valid_moves[pos] = nil if pos.all? { |dim| dim.between?(0, 7) }
#     end
#     @valid_moves.select! { |move, _| !board.occupied?(move) }
#   end
#
#   def jump_moves
#     x, y = @pos[0], @pos[1]
#     (0..3).each do |idx|
#       base_move = [x + BASE_DIFFS[idx][0], y + BASE_DIFFS[idx][1]]
#       next unless base_move.all? { |dim| dim.between?(0, 7) }
#       jump_move = [x + JUMP_DIFFS[idx][0], y + JUMP_DIFFS[idx][1]]
#       next unless jump_move.all? { |dim| dim.between?(0, 7) }
#       if enemy?(board[base_move]) && !board.occupied?(jump_move)
#         @valid_moves[jump_move] = base_move
#       end
#     end
#   end
# end

load './slidable.rb'

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
    return true if (@color == :red && piece.color == :black) ||
      (@color == :black && piece.color == :red)
    false
  end
end

class EmptySquare < Piece
  def initialize(color, pos, board)
    super(color, pos, board)
    color == :black ? @face = "   " : @face = "   "
  end

  def get_moves
    @valid_moves = []
  end
end

class Checker < Piece
  BASE_DIFFS = [[-1, -1], [-1, 1], [1, 1], [1, -1]]
  JUMP_DIFFS = [[-2, -2], [-2, 2], [2, 2], [2, -2]]
  def initialize(color, pos, board)
    super(color, pos, board)
    @face = color == :black ? " B " : " R "
  end

  def get_moves
    reset_moves
    base_moves
    jump_moves

  end

  def reset_moves
    @valid_moves, @jump_moves = {}, {}
  end

  def base_moves
    BASE_DIFFS.each do |diff|
      pos = [@pos[0] + diff[0], @pos[1] + diff[1]]
      @valid_moves[pos] = nil if pos.all? { |dim| dim.between?(0, 7) }
    end
    @valid_moves.select! { |move, _| !board.occupied?(move) }
  end

  def jump_moves
    x, y = @pos[0], @pos[1]
    (0..3).each do |idx|
      base_move = [x + BASE_DIFFS[idx][0], y + BASE_DIFFS[idx][1]]
      next unless base_move.all? { |dim| dim.between?(0, 7) }
      jump_move = [x + JUMP_DIFFS[idx][0], y + JUMP_DIFFS[idx][1]]
      next unless jump_move.all? { |dim| dim.between?(0, 7) }
      if enemy?(board[base_move]) && !board.occupied?(jump_move)
        @valid_moves[jump_move] = base_move
      end
    end
  end
end


# class Pawn < Pieces
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     color == :black ? @face = " ♟ " : @face = " ♙ "
#     @origin = pos.dup
#     @opponent_color = color == :black ? :white : :black
#   end
#
#   def get_moves
#     @available_moves = all_pawn_moves
#   end
#
#   def all_pawn_moves
#     result = []
#
#     if color == :black
#       v = pos[0]
#       h = pos[1]
#       result << [v + 1, h] if @board.on_board?([v + 1, h]) && @board.occupied?([v + 1, h]) == false
#       result << [v + 1, h - 1] if @board.on_board?([v + 1, h - 1]) && @board[[(v + 1), (h - 1)]].color == @opponent_color
#       result << [v + 1, h + 1] if @board.on_board?([v + 1, h + 1]) && @board[[(v + 1), (h + 1)]].color == @opponent_color
#       result << [v + 2, h] if pos == @origin && !@board.occupied?([(v + 2), h])
#     end
#
#     if color == :white
#       v = pos[0]
#       h = pos[1]
#       result << [v - 1, h] if @board.on_board?([v - 1, h]) && @board.occupied?([v - 1, h]) == false
#       result << [v - 1, h - 1] if @board.on_board?([v - 1, h - 1]) && @board[[(v - 1), (h - 1)]].color == @opponent_color
#       result << [v - 1, h + 1] if @board.on_board?([v - 1, h + 1]) && @board[[(v - 1), (h + 1)]].color == @opponent_color
#       result << [v - 2, h] if pos == @origin && !@board.occupied?([(v - 2), h])
#     end
#
#     result
#   end
#
# end
#
# class Bishop < Pieces
#   include Slidable
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     color == :black ? @face = " ♝ " : @face = " ♗ "
#   end
#
#   def get_moves
#     @available_moves = all_diagonal_moves
#   end
# end
#
# class Knight < Pieces
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     color == :black ? @face = " ♞ " : @face = " ♘ "
#   end
#
#   def get_moves
#     @available_moves = all_knight_moves
#   end
#
#   def all_knight_moves
#     result = []
#
#     [-2, 2, -1, 1].each do |v_offset|
#       [-2, 2, -1, 1].each do |h_offset|
#         if (v_offset * h_offset).abs == 2
#           v = v_offset + pos[0]
#           h = h_offset + pos[1]
#           next if !@board.on_board?([v, h])
#           unless @board.occupied?([v, h]) && @board[[v, h]].color == self.color
#             result << [v, h]
#           end
#         end
#       end
#     end
#
#     result
#   end
#
# end
#
# class Rook < Pieces
#   include Slidable
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     color == :black ? @face = " ♜ " : @face = " ♖ "
#   end
#
#   def get_moves
#     @available_moves = all_horizontal_moves
#     @available_moves += all_vertical_moves
#   end
# end
#
# class Queen < Pieces
#   include Slidable
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     color == :black ? @face = " ♛ " : @face = " ♕ "
#   end
#
#   def get_moves
#     @available_moves = all_horizontal_moves
#     @available_moves += all_vertical_moves
#     @available_moves += all_diagonal_moves
#   end
# end
#
# class King < Pieces
#   def initialize(color, pos, board)
#     super(color, pos, board)
#     color == :black ? @face = " ♚ " : @face = " ♔ "
#   end
#
#   def get_moves
#     @available_moves = all_king_moves
#   end
#
#   def all_king_moves
#     result = []
#
#     (-1..1).to_a.each do |v_offset|
#       (-1..1).to_a.each do |h_offset|
#         v = pos[0] + v_offset
#         h = pos[1] + h_offset
#         next unless @board.on_board?([v, h])
#         if ((v == pos[0]) && (h == pos[1])) || @board[[v, h]].color == color
#           next
#         else
#           result << [v, h]
#         end
#       end
#     end
#
#     result
#   end
# end

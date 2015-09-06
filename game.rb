require './board.rb'
require './display.rb'

class Game
  attr_accessor :display, :board

  def initialize
    @board = Board.new(true)
    @display = Display.new(@board)
  end

  def play
    loop do
      play_turn
    end
  end

  def play_turn
    # display.render
    Kernel.abort("#{@board.current_player} lost!") if @board.lost?

    start_pos = get_move
    until start_pos_ok?(start_pos)
      start_pos = get_move
    end
    @board[start_pos].selected = true

    destination = get_move until second_selection_ok?(start_pos, destination)
    @board[start_pos].selected = false
    return if start_pos == destination # allows deselection of start_pos

    board.make_move(start_pos, destination)
    @board.swap_players!
  end

  def get_move
    result = nil
    until result
      display.render
      result = @display.get_input
    end
    result
  end

  def start_pos_ok?(start_pos)
    start_pos && @board[start_pos].color == @board.current_player # => &&
    # !@board[start_pos].valid_moves.empty?
  end

  def second_selection_ok?(start_pos, destination)
    destination == start_pos || # allows deselection of start_pos
    destination &&
    @board[start_pos].valid_moves.keys.include?(destination) #&&
    # !@board.will_be_in_check?(start_pos, destination, @board.current_player)
  end
end

class UnoccupiedError < StandardError
end

class InvalidMoveError < StandardError
end

class InCheckError < StandardError
end

if $__FILE__ = $PROGRAM_NAME
  game = Game.new
  game.play
end

require './board.rb'
require './display.rb'
require 'byebug'
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
    gameover if @board.lost?

    start_pos = get_move until start_pos_ok?(start_pos)
    @board[start_pos].selected = true

    destination = get_move until second_selection_ok?(start_pos, destination)
    @board[start_pos].selected = false
    return if start_pos == destination

    jump_flag = board.make_move!(start_pos, destination)

    if jump_flag
      # byebug
      if @board[destination].can_jump?
        play_turn
        @board.swap_players!
      end
    end

    @board.swap_players!
  end

  def gameover
    display.render
    Kernel.abort("#{@board.current_player.capitalize} lost!")
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
    start_pos &&
    @board[start_pos].color == @board.current_player &&
    jumper_if_needed?(start_pos)
  end

  def jumper_if_needed?(start_pos)
    if @board.player_can_jump?
      @board[start_pos].can_jump? ? true : false
    else
      true
    end
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

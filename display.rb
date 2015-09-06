require 'colorize'
require './cursorable.rb'

class Display
  include Cursorable

  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
    nil
  end

  def build_grid
    @board.rows.map.with_index do |row, i|
      build_row(row, i)
    end
  end

  def build_row(row, i)
    row.map.with_index do |piece, j|
      color_options = colors_for(i, j)
      piece.face.to_s.colorize(color_options)
    end
  end

  def colors_for(i, j)
    if [i, j] == @cursor_pos
      bg = :green
    elsif @board[[i, j]].selected
      bg = :cyan
    elsif @board[@cursor_pos].valid_moves.keys.include?([i, j])
      if (i + j).odd?
        bg = :yellow
      else
        bg = :light_blue
      end
    elsif (i + j).even?
      bg = :light_white
    else
      bg = :light_black
    end
    { background: bg, color: :black }
  end

  def render
    system("clear")
    puts "Current player: #{@board.current_player.capitalize}"
    puts "Arrow keys or WASD for cardinal moves. QEZC for diagonal moves."
    puts "Enter or Space to select."
    build_grid.each do |row|
      puts row.join
    end
    puts "#{@board.current_player.capitalize} must jump!" if @board.player_can_jump?
    nil
  end
end

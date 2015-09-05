require 'colorize'
load 'cursorable.rb'

class Display
  include Cursorable

  def initialize(board)
    @board = board
    @cursor_pos = [0, 0]
    nil
  end

  def build_grid
    @board.rows.map.with_index do |row, i|
      # byebug
      build_row(row, i)
    end
  end

  def build_row(row, i)
    # byebug
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
    elsif @board[@cursor_pos].available_moves.include?([i, j])
      if (i + j).odd?
        bg = :blue
      else
        bg = :light_blue
      end
    elsif (i + j).even?
      bg = :light_red
    else
      bg = :light_black
    end
    { background: bg, color: :black }
  end

  def render
    system("clear")
    puts "#{@board.current_player}'s Turn!"
    puts "Arrow keys or WASD to move, Enter or Space to select."
    build_grid.each do |row|
      puts row.join
    end
    nil
  end

end

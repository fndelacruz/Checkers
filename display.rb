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
    elsif @board[@cursor_pos].available_moves.include?([i, j])
      if (i + j).odd?
        bg = :blue
      else
        bg = :light_blue
      end
    elsif (i + j).odd?
      bg = :light_black
    else
      bg = :light_white
    end
    { background: bg, color: :black }
  end

  def render
    system("clear")
    puts "#{@board.current_player}'s Turn!"
    puts "#{@board.current_player} is in check." if @board.currently_in_check?(@board.current_player)
    puts "Arrow keys or WASD to move, Enter or Space to select."
    build_grid.each do |row|

      puts row.join
    end
    nil
  end

end

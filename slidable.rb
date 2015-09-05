module Slidable

  def occupied?(pos)
    board[pos].class != EmptySquare
  end

  def all_horizontal_moves
    result = []

    v = pos[0]
    h = pos[1]
    result += horizontal_explore(((h + 1)..7).to_a, v)
    result += horizontal_explore((0...h).to_a.reverse, v)

    result#.select { |move| @board.will_be_in_check?(pos, move, color) }
  end

  def horizontal_explore(range, v)
    result = []

    range.each do |h|
      if @board[[v, h]].color == color
        break
      elsif @board.occupied?([v, h])
        result << [v, h]
        break
      else
        result << [v, h]
      end
    end

    result
  end

  def all_vertical_moves
    result = []

    v = pos[0]
    h = pos[1]
    result += vertical_explore(((v + 1)..7).to_a, h)
    result += vertical_explore((0...v).to_a.reverse, h)

    result#.select { |move| @board.will_be_in_check?(pos, move, color) }
  end

  def vertical_explore(range, h)
    result = []

    range.each do |v|
      if @board[[v, h]].color == color
        break
      elsif @board.occupied?([v, h])
        result << [v, h]
        break
      else
        result << [v, h]
      end
    end

    result
  end

  def all_diagonal_moves
    result = []

    [[1, 1], [-1, -1], [1, -1], [-1, 1]].each do |range|
      result += diagonal_explore(range)
    end

    result
  end

  def diagonal_explore(range)
    result = []

    v = pos[0] + range[0]
    h = pos[1] + range[1]
    while @board.on_board?([v, h])
      if @board[[v, h]].color == color
        break
      elsif @board.occupied?([v, h])
        result << [v, h]
        break
      else
        result << [v, h]
      end
      v += range[0]
      h += range[1]
    end

    result
  end
end

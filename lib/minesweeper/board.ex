defmodule Minesweeper.Board do
  defguardp is_dimension(value) when is_integer(value) and value >= 1

  defguard is_column(value) when is_dimension(value)
  defguard is_row(value) when is_dimension(value)

  defguard is_width(value) when is_dimension(value)
  defguard is_height(value) when is_dimension(value)

  defguard is_dimensions(value)
           when is_tuple(value) and tuple_size(value) == 2 and
                  is_width(elem(value, 0)) and is_height(elem(value, 1))

  def all_positions(width, height) when is_width(width) and is_height(height),
    do: for(col <- Range.new(1, width), row <- Range.new(1, height), do: [col, row])
end

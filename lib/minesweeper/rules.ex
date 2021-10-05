defmodule Minesweeper.Rules do
  import Minesweeper.Board, only: [is_dimensions: 1, is_column: 1, is_row: 1]
  alias Minesweeper.Board

  def uncover([col, row] = position, bombs, uncovered, {width, height} = dimensions)
      when is_column(col) and is_row(row) and
             is_list(bombs) and
             is_list(uncovered) and
             is_dimensions(dimensions) and
             col <= width and row <= height do
    if Enum.member?(bombs, position) do
      {:ok, :loss}
    else
      newly_revealed_positions = reveal_positions(position, bombs, uncovered, dimensions)

      if Board.all_positions(width, height) -- (uncovered ++ newly_revealed_positions) ==
           Enum.sort(bombs) do
        {
          :ok,
          {
            :win,
            newly_revealed_positions
            |> Enum.map(fn pos -> {pos, count_bombs_around(pos, bombs, dimensions)} end)
            |> Enum.sort()
          }
        }
      else
        {
          :ok,
          {
            :ongoing,
            newly_revealed_positions
            |> Enum.map(fn pos -> {pos, count_bombs_around(pos, bombs, dimensions)} end)
            |> Enum.sort()
          }
        }
      end
    end
  end

  def initialize_bombs({width, height} = dimensions, number_of_bombs, first_move = [col, row])
      when is_dimensions(dimensions) and
             is_integer(number_of_bombs) and number_of_bombs >= 1 and
             number_of_bombs < width * height - 1 and
             is_column(col) and is_row(row) do
    (Board.all_positions(width, height) -- [first_move])
    |> Enum.shuffle()
    |> Enum.take(number_of_bombs)
  end

  # FIXME: do not continue revealing positions past positions next to bombs
  defp reveal_positions([col, row] = position, bombs, uncovered, dimensions)
       when is_column(col) and is_row(row) do
    bomb_count = count_bombs_around(position, bombs, dimensions)

    if bomb_count != 0 do
      [position]
    else
      base =
        [position]
        |> contiguous_positions_not_next_to_bombs(bombs, uncovered, dimensions)

      Enum.uniq(base ++ positions_around(base, dimensions)) -- uncovered
    end
  end

  defp count_bombs_around(position, bombs, dimensions) do
    positions_around(position, dimensions)
    |> Enum.filter(fn pos -> Enum.member?(bombs, pos) end)
    |> length()
  end

  defp contiguous_positions_not_next_to_bombs(positions, bombs, uncovered, dimensions) do
    new_positions =
      Enum.filter(
        positions_around(positions, dimensions) -- (positions ++ bombs ++ uncovered),
        fn pos -> count_bombs_around(pos, bombs, dimensions) == 0 end
      )

    if new_positions == [] do
      positions
    else
      contiguous_positions_not_next_to_bombs(
        positions ++ new_positions,
        bombs,
        uncovered,
        dimensions
      )
    end
  end

  defp contiguous_positions_without_bombs(positions, bombs, uncovered, dimensions) do
    new_positions = positions_around(positions, dimensions) -- (positions ++ bombs ++ uncovered)

    if new_positions == [] do
      positions
    else
      contiguous_positions_without_bombs(
        positions ++ new_positions,
        bombs,
        uncovered,
        dimensions
      )
    end
  end

  defp positions_around([col, row], {width, height}) when is_column(col) and is_row(row),
    do:
      for(
        dx <- -1..1,
        dy <- -1..1,
        dx != 0 || dy != 0,
        col + dx >= 1,
        col + dx <= width,
        row + dy >= 1,
        row + dy <= height,
        do: [col + dx, row + dy]
      )

  defp positions_around(positions, dimensions) when is_list(positions) do
    positions
    |> Enum.flat_map(fn pos -> positions_around(pos, dimensions) end)
    |> Enum.uniq()
  end
end

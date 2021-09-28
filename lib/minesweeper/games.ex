defmodule Minesweeper.Games do
  alias Ecto.Multi
  alias Minesweeper.Games.Game
  alias Minesweeper.Games.Move

  def start_new_game(first_move = [col, row])
      when is_integer(col) and col >= 1 and col <= 30 and is_integer(row) and row >= 1 and
             row <= 16 do
    Multi.new()
    |> Multi.insert(:game, new_game(first_move), returning: [:id, :state])
    |> Multi.insert(:first_move, fn %{game: game} -> first_move_for(game, first_move) end)
  end

  defp new_game(first_move) do
    %Game{bombs: random_bombs(first_move) |> List.flatten()}
  end

  def first_move_for(game, first_move) do
    %Move{game: game, position: first_move, played_at: game.created_at}
  end

  defp random_bombs(first_move) do
    (all_positions() -- [first_move])
    |> Enum.shuffle()
    |> Enum.take(99)
  end

  defp all_positions, do: for(col <- 1..30, row <- 1..16, do: [col, row])
end

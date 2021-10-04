defmodule Minesweeper.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: Minesweeper.Repo

  alias Minesweeper.Board
  alias Minesweeper.Game
  alias Minesweeper.Move

  def game_factory() do
    {width, height} = {30, 16}

    %Game{
      width: width,
      height: height,
      state: :ongoing,
      bombs: Board.all_positions(30, 16) |> Enum.shuffle() |> Enum.take(99)
    }
  end

  def move_factory() do
    %Move{
      game: build(:game),
      position: [1, 1]
    }
  end
end

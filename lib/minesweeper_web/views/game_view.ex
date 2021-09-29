defmodule MinesweeperWeb.GameView do
  use MinesweeperWeb, :view

  alias Minesweeper.Game
  alias Minesweeper.Move

  def render("create.json", %{game: game, first_move: first_move}) do
    %Game{
      id: id,
      width: width,
      height: height,
      bombs: bombs,
      state: state,
      created_at: created_at
    } = game

    %Move{position: [col, row], played_at: played_at} = first_move

    %{
      id: id,
      width: width,
      height: height,
      bombs: length(bombs),
      state: state,
      moves: [
        %{
          position: [col, row],
          played_at: played_at
        }
      ],
      created_at: created_at
    }
  end
end

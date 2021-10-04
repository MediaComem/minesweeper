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

  def render("play.json", %{move: move}) do
    %Move{
      id: id,
      game: %Game{id: game_id},
      position: position,
      uncovered: uncovered,
      played_at: played_at
    } = move

    %{
      id: id,
      game_id: game_id,
      position: position,
      uncovered: Enum.map(uncovered, &Tuple.to_list/1),
      played_at: played_at
    }
  end
end

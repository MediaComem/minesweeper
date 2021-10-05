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

    %Move{position: [col, row], uncovered: uncovered, played_at: played_at} = first_move

    %{
      id: id,
      width: width,
      height: height,
      number_of_bombs: length(bombs),
      state: state,
      moves: [
        %{
          position: [col, row],
          uncovered: Enum.map(uncovered, &Tuple.to_list/1),
          played_at: played_at
        }
      ],
      created_at: created_at
    }
  end

  def render("play.json", %{move: move}) do
    %Move{
      id: id,
      game: %Game{id: game_id, state: state, bombs: bombs},
      position: position,
      uncovered: uncovered,
      played_at: played_at
    } = move

    game = %{
      id: game_id,
      state: state
    }

    game = if state == :win || state == :loss, do: Map.put(game, :bombs, bombs), else: game

    move = %{
      id: id,
      game_id: game_id,
      game: game,
      position: position,
      uncovered: if(uncovered, do: Enum.map(uncovered, &Tuple.to_list/1), else: nil),
      played_at: played_at
    }

    if uncovered, do: Map.put(move, :uncovered, Enum.map(uncovered, &Tuple.to_list/1)), else: move
  end
end

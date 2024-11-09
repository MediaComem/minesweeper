defmodule MinesweeperWeb.Game.GameView do
  use MinesweeperWeb, :html

  alias Minesweeper.Game
  alias Minesweeper.Move
  alias Minesweeper.Rules

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

  def render("show.json", %{game: game}) do
    %Game{
      id: id,
      width: width,
      height: height,
      bombs: bombs,
      state: state,
      created_at: created_at,
      moves: moves
    } = game

    {serialized_moves, _} =
      Enum.reduce(moves, {[], []}, fn move, {acc, uncovered} ->
        case Rules.uncover(move.position, bombs, uncovered, {width, height}) do
          {:ok, :loss} ->
            {acc ++ [move], uncovered}

          {:ok, {_, newly_revealed}} ->
            {acc ++ [%Move{move | uncovered: Enum.map(newly_revealed, &Tuple.to_list/1)}],
             uncovered ++ Enum.map(newly_revealed, &elem(&1, 0))}
        end
      end)

    %{
      id: id,
      width: width,
      height: height,
      number_of_bombs: length(bombs),
      state: state,
      created_at: created_at,
      moves:
        Enum.map(serialized_moves, fn move ->
          %Move{position: position, uncovered: uncovered} = move

          %{
            position: position
          }
          |> put_non_nil(:uncovered, uncovered)
        end)
    }
    |> put_if(:bombs, bombs, state == :win || state == :loss)
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

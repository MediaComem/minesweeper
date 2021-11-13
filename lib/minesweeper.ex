defmodule Minesweeper do
  @moduledoc """
  Minesweeper keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Minesweeper.Board, only: [is_column: 1, is_row: 1]
  alias Ecto.Multi
  alias Minesweeper.Game
  alias Minesweeper.GameServer
  alias Minesweeper.Move

  def start_new_game(params) when is_map(params) do
    Multi.new()
    |> Multi.insert(:game, Game.new(params), returning: [:id])
    |> Multi.insert(:first_move, fn %{game: game} -> Move.first(game.first_move, game) end)
  end

  def play(game_id, [col, row] = position)
      when is_binary(game_id) and is_column(col) and is_row(row) do
    # TODO: check game status
    with :ok <- GameServer.start_link(game_id) do
      GameServer.play(game_id, position)
    end
  end
end

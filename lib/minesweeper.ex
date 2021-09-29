defmodule Minesweeper do
  @moduledoc """
  Minesweeper keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias Ecto.Multi
  alias Minesweeper.Game
  alias Minesweeper.Move

  def start_new_game(params) when is_map(params) do
    Multi.new()
    |> Multi.insert(:game, Game.new(params), returning: [:id])
    |> Multi.insert(:first_move, fn %{game: game} -> Move.first(game.first_move, game) end)
  end
end

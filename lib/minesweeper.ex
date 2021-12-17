defmodule Minesweeper do
  @moduledoc """
  Minesweeper keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query, only: [from: 2]
  import Minesweeper.Board, only: [is_column: 1, is_row: 1]

  alias Ecto.Multi
  alias Ecto.UUID
  alias Minesweeper.Game
  alias Minesweeper.GameServer
  alias Minesweeper.Move
  alias Minesweeper.Repo

  def start_game(params) when is_map(params) do
    Multi.new()
    |> Multi.insert(:game, Game.new(params), returning: [:id])
    |> Multi.insert(:first_move, fn %{game: game} -> Move.first(game.first_move, game) end)
    |> Repo.transaction()
  end

  def find_game(id) when is_binary(id) do
    with {:ok, game_id} <- cast_game_id(id) do
      case Repo.one(from g in Game, where: g.id == ^game_id, preload: :moves) do
        nil -> {:error, {:not_found, :game}}
        game -> {:ok, game}
      end
    end
  end

  def list_games() do
    games =
      Repo.all(
        from g in Game,
          where: g.state in [:win, :loss],
          order_by: [desc: g.updated_at],
          preload: :moves
      )

    {:ok, games}
  end

  def play(id, [col, row] = position)
      when is_binary(id) and is_column(col) and is_row(row) do
    with {:ok, game_id} <- cast_game_id(id),
         :ok <- ensure_game_ongoing(game_id),
         {:ok, _} <- GameServer.start_link(game_id) do
      GameServer.play(game_id, position)
    end
  end

  defp ensure_game_ongoing(game_id) do
    case Repo.one(from(g in Game, select: g.state, where: g.id == ^game_id)) do
      :ongoing -> :ok
      nil -> {:error, {:not_found, :game}}
      state when is_atom(state) -> {:error, {:game_done, state}}
    end
  end

  defp cast_game_id(id) do
    case UUID.cast(id) do
      {:ok, uuid} -> {:ok, uuid}
      _ -> {:error, {:not_found, :game}}
    end
  end
end

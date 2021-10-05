# TODO: shut down game server when game is done
defmodule Minesweeper.GameServer do
  use GenServer

  import Ecto.Query, only: [from: 2]
  import Minesweeper.Board, only: [is_column: 1, is_row: 1]

  alias Ecto.Changeset
  alias Ecto.Multi
  alias Minesweeper.Game
  alias Minesweeper.Move
  alias Minesweeper.Repo
  alias Minesweeper.Rules

  defmodule State do
    @type t :: %__MODULE__{
            game: Game.t()
          }

    @enforce_keys [:game]
    defstruct [:game]
  end

  def start_link(id) when is_binary(id) do
    case GenServer.start_link(__MODULE__, id, name: {:global, {__MODULE__, id}}) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  def play(id, [col, row] = position) when is_column(col) and is_row(row) do
    GenServer.call({:global, {__MODULE__, id}}, {:play, position})
  end

  # Server (callbacks)

  @impl true
  def init(id) when is_binary(id) do
    {:ok, nil, {:continue, id}}
  end

  @impl true
  def handle_continue(id, _) do
    game =
      from(g in Game, where: g.id == ^id)
      |> Repo.one()
      |> Repo.preload(:moves)

    {enriched_moves, _} =
      Enum.reduce(game.moves, {[], []}, fn move, {moves, acc} ->
        {:ok, {:ongoing, uncovered}} =
          Rules.uncover(move.position, game.bombs, acc, {game.width, game.height})

        {moves ++ [%Move{move | uncovered: uncovered}],
         acc ++ Enum.map(uncovered, fn {pos, _} -> pos end)}
      end)

    {:noreply, %State{game: %Game{game | moves: enriched_moves}}}
  end

  @impl true
  def handle_call({:play, position}, _from, state) do
    %State{game: %Game{width: width, height: height, bombs: bombs, moves: moves} = game} = state
    uncovered_positions = Enum.map(moves, fn move -> move.position end)

    {:ok, result} = Rules.uncover(position, bombs, uncovered_positions, {width, height})

    with {:ok, %{game: updated_game, move: created_move}} <- persist_move(game, position, result) do
      {:reply, {:ok, created_move}, %State{state | game: updated_game}}
    else
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end

  defp persist_move(game, position, {:ongoing, uncovered}) do
    Multi.new()
    |> Multi.put(:game, game)
    |> Multi.insert(
      :move,
      build_move(game, position, uncovered),
      returning: [:id]
    )
    |> Repo.transaction()
  end

  defp persist_move(game, position, {:win, uncovered}) do
    Multi.new()
    |> Multi.update(:game, Changeset.change(game, state: :win))
    |> Multi.insert(
      :move,
      fn %{game: updated_game} -> build_move(updated_game, position, uncovered) end,
      returning: [:id]
    )
    |> Repo.transaction()
  end

  defp persist_move(game, position, :loss) do
    Multi.new()
    |> Multi.update(:game, Changeset.change(game, state: :loss))
    |> Multi.insert(
      :move,
      fn %{game: game} -> build_move(game, position) end,
      returning: [:id]
    )
    |> Repo.transaction()
  end

  defp build_move(game, position, uncovered \\ nil) do
    %Move{
      game: Game.shallow(game),
      position: position,
      uncovered: uncovered
    }
  end
end

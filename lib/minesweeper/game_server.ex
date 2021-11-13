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
            game: Game.t(),
            uncovered: list()
          }

    @enforce_keys [:game]
    defstruct [:game, uncovered: nil]
  end

  def start_link(game_id) when is_binary(game_id) do
    case GenServer.start_link(__MODULE__, game_id, name: {:global, {__MODULE__, game_id}}) do
      {:ok, _} -> :ok
      {:error, {:already_started, _}} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  def play(game_id, [col, row] = position)
      when is_binary(game_id) and is_column(col) and is_row(row) do
    GenServer.call({:global, {__MODULE__, game_id}}, {:play, position})
  end

  # Server (callbacks)

  @impl true
  def init(game_id) when is_binary(game_id) do
    {:ok, nil, {:continue, game_id}}
  end

  @impl true
  def handle_continue(game_id, _) do
    game =
      from(g in Game, where: g.id == ^game_id)
      |> Repo.one()
      |> Repo.preload(:moves)

    {enriched_moves, all_uncovered} =
      Enum.reduce(game.moves, {[], []}, fn move, {moves, acc} ->
        {:ok, {:ongoing, uncovered}} =
          Rules.uncover(move.position, game.bombs, acc, {game.width, game.height})

        {moves ++ [%Move{move | uncovered: uncovered}],
         acc ++ Enum.map(uncovered, fn {pos, _} -> pos end)}
      end)

    {:noreply, %State{game: %Game{game | moves: enriched_moves}, uncovered: all_uncovered}}
  end

  @impl true
  def handle_call({:play, position}, _from, state) do
    %State{
      game: %Game{width: width, height: height, bombs: bombs} = game,
      uncovered: uncovered_positions
    } = state

    {:ok, result} = Rules.uncover(position, bombs, uncovered_positions, {width, height})

    with {:ok, %{game: updated_game, move: created_move}} <- persist_move(game, position, result) do
      {:reply, {:ok, created_move},
       %State{
         state
         | game: updated_game,
           uncovered: uncovered_positions ++ Enum.map(created_move.uncovered || [], &elem(&1, 0))
       }}
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

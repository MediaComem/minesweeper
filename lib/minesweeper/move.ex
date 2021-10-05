defmodule Minesweeper.Move do
  use Ecto.Schema

  import Minesweeper.Board, only: [is_column: 1, is_row: 1]

  alias Minesweeper.Game
  alias Minesweeper.Rules

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "moves" do
    belongs_to :game, Game
    field :position, {:array, :integer}
    field :uncovered, {:array, {:array, :integer}}, virtual: true
    timestamps inserted_at: :played_at, updated_at: false
  end

  def first(position = [col, row], game) when is_column(col) and is_row(row) do
    {:ok, {_state, uncovered}} =
      Rules.uncover(position, game.bombs, [], {game.width, game.height})

    %__MODULE__{
      game: game,
      position: position,
      uncovered: uncovered,
      played_at: game.created_at
    }
  end
end

defmodule Minesweeper.Move do
  use Ecto.Schema

  import Minesweeper.Board, only: [is_column: 1, is_row: 1]

  alias Minesweeper.Game

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "moves" do
    field :position, {:array, :integer}
    belongs_to :game, Game
    timestamps inserted_at: :played_at, updated_at: false
  end

  def first(position = [col, row], game) when is_column(col) and is_row(row) do
    %__MODULE__{game: game, position: position, played_at: game.created_at}
  end
end

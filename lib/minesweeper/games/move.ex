defmodule Minesweeper.Games.Move do
  use Ecto.Schema

  alias Minesweeper.Games.Game

  @primary_key {:id, :binary_id, autogenerate: false}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime_usec]

  schema "moves" do
    field :position, {:array, :integer}
    belongs_to :game, Game
    timestamps inserted_at: :played_at, updated_at: false
  end
end

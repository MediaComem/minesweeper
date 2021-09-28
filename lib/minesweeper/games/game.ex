defmodule Minesweeper.Games.Game do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "games" do
    field :state, Ecto.Enum, values: [:ongoing, :win, :loss]
    field :bombs, {:array, :integer}
    timestamps inserted_at: :created_at
  end
end

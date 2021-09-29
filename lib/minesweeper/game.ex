defmodule Minesweeper.Game do
  use Ecto.Schema

  import Ecto.Changeset
  import Minesweeper.Board, only: [is_width: 1, is_height: 1, is_column: 1, is_row: 1]

  alias Ecto.Changeset
  alias Minesweeper.Game
  alias Minesweeper.Rules

  @primary_key {:id, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "games" do
    field :width, :integer
    field :height, :integer
    field :number_of_bombs, :integer, virtual: true
    field :first_move, {:array, :integer}, virtual: true
    field :state, Ecto.Enum, values: [:ongoing, :win, :loss]
    field :bombs, {:array, {:array, :integer}}
    timestamps inserted_at: :created_at
  end

  def new(params) when is_map(params) do
    changes =
      %Game{}
      |> cast(params, [:width, :height, :number_of_bombs, :first_move])
      |> validate_required([:width, :height, :number_of_bombs, :first_move])
      |> validate_number(:width, greater_than_or_equal_to: 2, less_than_or_equal_to: 100)
      |> validate_number(:height, greater_than_or_equal_to: 2, less_than_or_equal_to: 100)

    changes
    |> validate_number_of_bombs()
    |> validate_first_move()
    |> prepare_changes(fn %Changeset{
                            changes: %{
                              width: width,
                              height: height,
                              number_of_bombs: number_of_bombs,
                              first_move: first_move
                            }
                          } = changeset ->
      changeset
      |> put_change(:bombs, Rules.initialize_bombs({width, height}, number_of_bombs, first_move))
      |> put_change(:state, :ongoing)
    end)
  end

  defp validate_number_of_bombs(%Changeset{changes: %{width: width, height: height}} = changeset)
       when is_width(width) and is_height(height) do
    changeset
    |> validate_number(:number_of_bombs,
      greater_than_or_equal_to: 1,
      less_than: width * height - 1
    )
  end

  defp validate_number_of_bombs(changeset), do: changeset

  defp validate_first_move(%Changeset{changes: %{width: width, height: height}} = changeset)
       when is_width(width) and is_height(height) do
    changeset
    |> validate_change(:first_move, fn :first_move, first_move ->
      case first_move do
        [col, row] when is_column(col) and col <= width and is_row(row) and row <= height -> []
        _ -> [first_move: "is not a valid position"]
      end
    end)
  end

  defp validate_first_move(changeset), do: changeset
end

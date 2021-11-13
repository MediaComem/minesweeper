defmodule Minesweeper.Game do
  use Ecto.Schema

  import Ecto.Changeset
  import Minesweeper.Board, only: [is_width: 1, is_height: 1, is_column: 1, is_row: 1]

  alias Ecto.Changeset
  alias Ecto.Enum
  alias Minesweeper.Game
  alias Minesweeper.Move
  alias Minesweeper.Rules

  @primary_key {:id, :binary_id, autogenerate: false}
  @timestamps_opts [type: :utc_datetime_usec]

  schema "games" do
    field :width, :integer
    field :height, :integer
    field :number_of_bombs, :integer, virtual: true
    field :first_move, {:array, :integer}, virtual: true
    field :state, Enum, values: [:ongoing, :win, :loss]
    field :bombs, {:array, {:array, :integer}}
    has_many :moves, Move
    timestamps inserted_at: :created_at
  end

  def new(params) when is_map(params) do
    changes =
      %Game{}
      |> cast(params, [:width, :height, :number_of_bombs, :first_move])
      |> validate_required([:width, :height, :number_of_bombs, :first_move])
      |> validate_number(:width, greater_than_or_equal_to: 2, less_than_or_equal_to: 100)
      |> validate_number(:height, greater_than_or_equal_to: 2, less_than_or_equal_to: 100)
      |> validate_number(:number_of_bombs, greater_than_or_equal_to: 1)
      |> validate_change(:first_move, fn :first_move, first_move ->
        case first_move do
          [col, row] when is_column(col) and is_row(row) -> []
          _ -> [first_move: "is not a column and row pair"]
        end
      end)

    changes
    |> validate_number_of_bombs_fits_board()
    |> validate_first_move()
    |> prepare_changes(fn %Changeset{
                            changes: %{
                              width: width,
                              height: height,
                              number_of_bombs: number_of_bombs,
                              first_move: first_move
                            }
                          } = changeset ->
      bombs = Rules.initialize_bombs({width, height}, number_of_bombs, first_move)

      {:ok, {state, _uncovered}} = Rules.uncover(first_move, bombs, [], {width, height})

      changeset
      |> put_change(
        :bombs,
        bombs
      )
      |> put_change(:state, state)
    end)
  end

  def shallow(game) do
    %__MODULE__{game | moves: %__MODULE__{}.moves}
  end

  defp validate_number_of_bombs_fits_board(
         %Changeset{changes: %{width: width, height: height}} = changeset
       )
       when is_width(width) and is_height(height) do
    validate_number(changeset, :number_of_bombs, less_than: width * height - 1)
  end

  defp validate_number_of_bombs_fits_board(changeset), do: changeset

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

defmodule Minesweeper.GameTest do
  use ExUnit.Case, async: true

  alias Ecto.Changeset
  alias Minesweeper.Game

  @valid_params %{
    "width" => 30,
    "height" => 16,
    "number_of_bombs" => 99,
    "first_move" => [2, 3]
  }

  test "create a valid game" do
    assert errors_for(@valid_params) == %{}
  end

  test "a game with no parameters is invalid" do
    assert %{
             width: %{validation: :required},
             height: %{validation: :required},
             number_of_bombs: %{validation: :required},
             first_move: %{validation: :required}
           } = errors_for(%{})
  end

  test "the width must be greater than or equal to 2" do
    for invalid_width <- [-3, 0, 1] do
      assert %{
               width: %{validation: :number, kind: :greater_than_or_equal_to, number: 2}
             } = errors_for(Map.put(@valid_params, "width", invalid_width))
    end
  end

  test "the height must be greater than or equal to 2" do
    for invalid_height <- [-3, 0, 1] do
      assert %{
               height: %{validation: :number, kind: :greater_than_or_equal_to, number: 2}
             } = errors_for(Map.put(@valid_params, "height", invalid_height))
    end
  end

  defp errors_for(params) when is_map(params), do: errors(Game.new(params))

  defp errors(%Changeset{} = changeset) do
    changeset.errors
    |> Enum.reduce(%{}, fn {field, {_msg, options}}, acc ->
      Map.put(acc, field, Enum.into(options, %{}))
    end)
  end
end

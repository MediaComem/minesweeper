defmodule Minesweeper.BoardTest do
  use ExUnit.Case, async: true

  alias Minesweeper.Board
  require Minesweeper.Board

  @valid_dimensions [1, 2, 3, 4, 5, 10, 100, 1000]
  @invalid_dimensions [-1000, -100, -50, -25, -10, -5, -4, -3, -2, -1, 0]

  test "validate board dimensions" do
    for dim <- @valid_dimensions do
      assert Board.is_width(dim) == true
      assert Board.is_height(dim) == true
      assert Board.is_column(dim) == true
      assert Board.is_row(dim) == true
    end

    for dim <- @invalid_dimensions do
      assert Board.is_width(dim) == false
      assert Board.is_height(dim) == false
      assert Board.is_column(dim) == false
      assert Board.is_row(dim) == false
    end

    assert Board.is_dimensions({1, 1}) == true
    assert Board.is_dimensions({1, 2}) == true
    assert Board.is_dimensions({3, 1}) == true
    assert Board.is_dimensions({500, 1000}) == true
    assert Board.is_dimensions({0, 0}) == false
    assert Board.is_dimensions({1, 0}) == false
    assert Board.is_dimensions({-1, 2}) == false
    assert Board.is_dimensions({500, 0}) == false
  end
end

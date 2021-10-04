defmodule Minesweeper.RulesTest do
  use ExUnit.Case, async: true

  alias Minesweeper.Rules

  @positions_2x2 [[1, 1], [1, 2], [2, 1], [2, 2]]
  @positions_3x3 [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3], [3, 1], [3, 2], [3, 3]]

  defdelegate uncover(position, bombs, uncovered, dimensions), to: Rules

  test "win on a 1x1 board" do
    # ┌─┐
    # │x│ x == 0
    # └─┘
    assert uncover([1, 1], [], [], {1, 1}) == {:ok, {:win, []}}
  end

  test "lose on a 1x1 board" do
    # ┌─┐
    # │x│ x == *
    # └─┘
    assert uncover([1, 1], [[1, 1]], [], {1, 1}) == {:ok, {:loss, [[1, 1]]}}
  end

  test "win on the third move on a 2x2 board with one bomb" do
    # ┌──┐
    # │1x│
    # │*1│
    # └──┘
    bomb_position = [1, 2]

    assert uncover([2, 1], [bomb_position], [[1, 1], [2, 2]], {2, 2}) ==
             {:ok, {:win, [bomb_position]}}
  end

  test "lose on the first move on a 2x2 board with one bomb" do
    # ┌──┐
    # │xx│ x == *
    # │xx│
    # └──┘
    for bomb_position <- @positions_2x2 do
      assert uncover(bomb_position, [bomb_position], [], {2, 2}) ==
               {:ok, {:loss, [bomb_position]}}
    end
  end

  test "lose on a 2x2 board filled with bombs" do
    # ┌──┐
    # │**│
    # │**│
    # └──┘
    for position <- @positions_2x2 do
      assert uncover(position, @positions_2x2, [], {2, 2}) == {:ok, {:loss, @positions_2x2}}
    end
  end

  test "reveal 1 surrounding bomb on a 3x3 board with a bomb in the middle" do
    # ┌───┐
    # │xxx│ x == 1
    # │x*x│
    # │xxx│
    # └───┘
    bomb_position = [2, 2]

    for target_position <- @positions_3x3 -- [bomb_position] do
      assert uncover(target_position, [bomb_position], [], {3, 3}) ==
               {:ok, {:ongoing, [{target_position, 1}]}}
    end
  end

  test "reveal a position next to one bomb on a 3x3 board" do
    # ┌───┐
    # │* x│ x == 1
    # │** │
    # │ * │
    # └───┘
    bomb_positions = [[1, 1], [1, 2], [2, 2], [2, 3]]
    target_position = [3, 1]

    assert uncover(target_position, bomb_positions, [], {3, 3}) ==
             {:ok, {:ongoing, [{target_position, 1}]}}
  end

  test "reveal a position next to two bombs on a 3x3 board" do
    # ┌───┐
    # │*  │ x == 2
    # │**x│
    # │ * │
    # └───┘
    bomb_positions = [[1, 1], [1, 2], [2, 2], [2, 3]]
    target_position = [3, 2]

    assert uncover(target_position, bomb_positions, [], {3, 3}) ==
             {:ok, {:ongoing, [{target_position, 2}]}}
  end

  test "reveal a position next to three bombs on a 3x3 board" do
    # ┌───┐
    # │*x │ x == 3
    # │** │
    # │ * │
    # └───┘
    bomb_positions = [[1, 1], [1, 2], [2, 2], [2, 3]]
    target_position = [2, 1]

    assert uncover(target_position, bomb_positions, [], {3, 3}) ==
             {:ok, {:ongoing, [{target_position, 3}]}}
  end

  test "reveal a position next to one bombs on a 3x3 board with other positions already revealed" do
    # ┌───┐
    # │*3x│ x == 1
    # │**2│
    # │ *2│
    # └───┘
    bomb_positions = [[1, 1], [1, 2], [2, 2], [2, 3]]
    uncovered = [[2, 1], [3, 2], [3, 3]]
    target_position = [2, 1]

    assert uncover(target_position, bomb_positions, uncovered, {3, 3}) ==
             {:ok, {:ongoing, [{target_position, 3}]}}
  end

  test "reveal one position on a 5x5 board" do
    # ┌─────┐
    # │   * │
    # │ **  │
    # │*  x │ x == 2
    # │** * │
    # │  * *│
    # └─────┘
    bomb_positions = [[1, 3], [1, 4], [2, 2], [2, 4], [3, 2], [3, 5], [4, 1], [4, 4], [5, 5]]
    uncovered = []
    target_position = [4, 3]

    assert uncover(target_position, bomb_positions, uncovered, {5, 5}) ==
             {:ok, {:ongoing, [{[4, 3], 2}]}}
  end

  test "reveal an island on a 5x5 board" do
    # ┌─────┐
    # │  **1│
    # │***31│
    # │*631x│ x == 0
    # │**432│
    # │ ****│
    # └─────┘
    bomb_positions = [
      [1, 2],
      [1, 3],
      [1, 4],
      [2, 2],
      [2, 4],
      [2, 5],
      [3, 1],
      [3, 2],
      [3, 5],
      [4, 1],
      [4, 5],
      [5, 5]
    ]

    uncovered = []
    target_position = [5, 3]

    expected_revealed =
      Enum.sort([
        {[2, 3], 6},
        {[3, 3], 3},
        {[3, 4], 4},
        {[4, 2], 3},
        {[4, 3], 1},
        {[4, 4], 3},
        {[5, 1], 1},
        {[5, 2], 1},
        {[5, 3], 0},
        {[5, 4], 2}
      ])

    assert uncover(target_position, bomb_positions, uncovered, {5, 5}) ==
             {:ok, {:ongoing, expected_revealed}}
  end

  test "almost reveal an entire 5x5 board" do
    # ┌─────┐
    # │12**1│
    # │2*321│
    # │*4200│
    # │**432│
    # │ ****│
    # └─────┘
    bomb_positions = [
      [1, 3],
      [1, 4],
      [2, 2],
      [2, 4],
      [2, 5],
      [3, 1],
      [3, 5],
      [4, 1],
      [4, 5],
      [5, 5]
    ]

    uncovered = []
    target_positions = [[4, 3], [5, 3]]

    expected_revealed =
      Enum.sort([
        {[1, 1], 1},
        {[1, 2], 2},
        {[2, 1], 2},
        {[2, 3], 4},
        {[3, 2], 3},
        {[3, 3], 2},
        {[3, 4], 4},
        {[4, 2], 2},
        {[4, 3], 0},
        {[4, 4], 3},
        {[5, 1], 1},
        {[5, 2], 1},
        {[5, 3], 0},
        {[5, 4], 2}
      ])

    for target_position <- target_positions do
      assert uncover(target_position, bomb_positions, uncovered, {5, 5}) ==
               {:ok, {:ongoing, expected_revealed}}
    end
  end
end

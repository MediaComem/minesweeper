defmodule Minesweeper.ApplicationTest do
  use ExUnit.Case

  test "start the application" do
    :ok = Application.stop(:minesweeper)
    :ok = Application.start(:minesweeper)
  end

  test "change the configuration" do
    assert Minesweeper.Application.config_change([], [], []) == :ok
  end
end

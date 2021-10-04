defmodule Minesweeper.TestUtils do
  @uuid_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

  def uuid_regexp() do
    @uuid_regexp
  end
end

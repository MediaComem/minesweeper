defmodule MinesweeperWeb.GameView do
  use MinesweeperWeb, :view

  def render("create.json", %{data: data}) do
    %{data: data}
  end
end

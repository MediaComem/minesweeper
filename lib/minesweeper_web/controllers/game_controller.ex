defmodule MinesweeperWeb.GameController do
  use MinesweeperWeb, :controller

  def create(conn, %{"data" => data}) do
    render(conn, "create.json", %{data: data})
  end
end

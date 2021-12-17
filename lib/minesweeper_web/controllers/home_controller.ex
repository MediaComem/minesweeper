defmodule MinesweeperWeb.HomeController do
  use MinesweeperWeb, :controller

  def index(conn, _params) do
    with {:ok, games} <- Minesweeper.list_games() do
      render(conn, "index.html", games: games)
    end
  end
end

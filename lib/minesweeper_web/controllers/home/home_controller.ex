defmodule MinesweeperWeb.Home.HomeController do
  use MinesweeperWeb, :controller

  def index(conn, _params) do
    with {:ok, games} <- Minesweeper.list_games() do
      render(conn, :index, games: games)
    end
  end
end

defmodule MinesweeperWeb.GameController do
  use MinesweeperWeb, :controller

  alias Minesweeper.Games
  alias Minesweeper.Repo

  def create(conn, %{"first_move" => [col, row]}) do
    {:ok, %{game: game, first_move: first_move}} =
      Games.start_new_game([col, row]) |> Repo.transaction()

    render(conn, "create.json", %{game: game, first_move: first_move})
  end
end

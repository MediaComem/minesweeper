defmodule MinesweeperWeb.GameController do
  use MinesweeperWeb, :controller

  alias Minesweeper
  alias Minesweeper.Repo

  def create(conn, params) do
    {:ok, %{game: game, first_move: first_move}} =
      Minesweeper.start_new_game(params)
      |> Repo.transaction()

    render(conn, "create.json", %{game: game, first_move: first_move})
  end

  def play(conn, params) do
    with {:ok, move} <- Minesweeper.play(params) do
      render(conn, "play.json", %{move: move})
    end
  end
end

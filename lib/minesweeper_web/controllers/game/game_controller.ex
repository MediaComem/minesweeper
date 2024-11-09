defmodule MinesweeperWeb.Game.GameController do
  use MinesweeperWeb, :controller

  alias Minesweeper
  import Ecto.Changeset
  import Minesweeper.Board, only: [is_column: 1, is_row: 1]

  @move_params_type %{id: :string, position: {:array, :integer}}

  action_fallback FallbackController

  def create(conn, params) do
    with {:ok, %{game: game, first_move: first_move}} <- Minesweeper.start_game(params) do
      conn
      |> put_status(:created)
      |> render("create.json", %{game: game, first_move: first_move})
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, game} <- Minesweeper.find_game(id) do
      conn
      |> render("show.json", %{game: game})
    end
  end

  def play(conn, params) do
    with {:ok, %{id: id, position: position}} <- validate_play_params(params),
         {:ok, move} <- Minesweeper.play(id, position) do
      conn
      |> put_status(:created)
      |> render("play.json", %{move: move})
    end
  end

  defp validate_play_params(params) when is_map(params) do
    {%{}, @move_params_type}
    |> cast(params, Map.keys(@move_params_type))
    |> validate_required([:id, :position])
    |> validate_change(:position, fn :position, position ->
      case position do
        [col, row] when is_column(col) and is_row(row) -> []
        _ -> [position: "is not a column and row pair"]
      end
    end)
    |> apply_action(:update)
  end
end

defmodule MinesweeperWeb.FallbackController do
  use MinesweeperWeb, :controller

  alias Ecto.Changeset

  def call(conn, {:error, {:not_found, resource}}) do
    conn
    |> put_status(:not_found)
    |> put_view(MinesweeperWeb.ErrorView)
    |> render("404.json", %{resource: resource})
  end

  def call(conn, {:error, {:game_done, state}}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(MinesweeperWeb.ErrorView)
    |> render("422.json", %{error: %{"code" => "game_done", "state" => state}})
  end

  def call(conn, {:error, %Changeset{} = changeset}) do
    send_validation_errors(conn, changeset)
  end

  def call(conn, {:error, _, %Changeset{} = changeset, %{}}) do
    send_validation_errors(conn, changeset)
  end

  defp send_validation_errors(conn, %Changeset{} = changeset) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(MinesweeperWeb.ErrorView)
    |> render("422.json", %{changeset: changeset})
  end
end

defmodule MinesweeperWeb.ErrorsViewTest do
  use MinesweeperWeb.ConnCase, async: true

  alias MinesweeperWeb.Errors.ErrorsView
  alias Plug.Conn

  import Phoenix.Template, only: [render_to_string: 4]

  setup %{conn: conn} do
    {:ok, conn: Conn.put_private(conn, :phoenix_endpoint, @endpoint)}
  end

  test "render API internal server error" do
    assert ErrorsView.render("500.json", %{}) == %{"code" => "unexpected_error"}
  end

  test "render page not found error", %{conn: conn} do
    assert render_to_string(ErrorsView, "404", "html", conn: conn) =~ "Page not found"

    render_to_string(ErrorsView, "404", "html", conn: %Conn{conn | status: 404})
    |> assert_html("code", "404")
    |> assert_html("h1", "Page not found")
  end

  test "render specific error", %{conn: conn} do
    render_to_string(ErrorsView, "418", "html", conn: %Conn{conn | status: 418})
    |> assert_html("code", "418")
    |> assert_html("h1", escape_html("I'm a teapot"))
  end

  test "render internal server error", %{conn: conn} do
    render_to_string(ErrorsView, "500", "html", conn: %Conn{conn | status: 500})
    |> assert_html("code", "500")
    |> assert_html("h1", "Internal Server Error")
  end
end

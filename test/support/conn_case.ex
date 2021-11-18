defmodule MinesweeperWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use MinesweeperWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  alias Minesweeper.Repo
  alias Phoenix.HTML

  import Ecto.Query, only: [from: 2]

  using do
    quote do
      # Import conveniences for testing with connections and views
      import AssertHTML
      import Plug.Conn
      import Phoenix.ConnTest
      import MinesweeperWeb.ConnCase

      alias MinesweeperWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint MinesweeperWeb.Endpoint
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Minesweeper.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Minesweeper.Repo, {:shared, self()})
    end

    {:ok, conn: Phoenix.ConnTest.build_conn(), now: DateTime.utc_now()}
  end

  def assert_validation_errors(%{"errors" => actual_errors} = body, expected_errors) do
    assert %{body | "errors" => sort_validation_errors(actual_errors)} ==
             %{"code" => "invalid_data", "errors" => sort_validation_errors(expected_errors)}
  end

  def assert_database_counts(expected_counts) do
    assert Map.merge(
             all_schemas() |> Enum.reduce(%{}, fn schema, acc -> Map.put(acc, schema, 0) end),
             expected_counts
           ) == count_database_records()
  end

  def escape_html(value) when is_binary(value) do
    value |> HTML.html_escape() |> HTML.safe_to_string()
  end

  defp count_database_records() do
    all_schemas()
    |> Enum.map(fn schema ->
      {schema, Task.async(fn -> Repo.one(from r in schema, select: count(r.id)) end)}
    end)
    |> Enum.map(fn {schema, task} -> {schema, Task.await(task)} end)
    |> Enum.into(%{})
  end

  defp sort_validation_errors(errors) do
    errors |> Enum.sort_by(& &1["path"]) |> Enum.sort_by(& &1["message"])
  end

  defp all_schemas() do
    {:ok, modules} = :application.get_key(:minesweeper, :modules)

    modules
    |> Enum.filter(&({:__schema__, 1} in &1.__info__(:functions)))
  end
end

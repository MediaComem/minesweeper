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

  import Ecto.Query, only: [from: 2]

  using do
    quote do
      # Import conveniences for testing with connections
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
             %{"errors" => sort_validation_errors(expected_errors)}
  end

  def count_records do
    {:ok, modules} = :application.get_key(:minesweeper, :modules)

    modules
    |> Enum.filter(&({:__schema__, 1} in &1.__info__(:functions)))
    |> Enum.map(fn schema ->
      {schema, Task.async(fn -> Repo.one(from r in schema, select: count(r.id)) end)}
    end)
    |> Enum.map(fn {schema, task} -> {schema, Task.await(task)} end)
    |> Enum.into(%{})
  end

  defp sort_validation_errors(errors) do
    Enum.sort(errors, fn err1, err2 ->
      compare(err1, err2, ["path", "message"])
    end)
  end

  defp compare(_map1, _map2, []) do
    true
  end

  defp compare(map1, map2, [property | rest]) do
    if map1[property] == map2[property] do
      compare(map1, map2, rest)
    else
      map1[property] < map2[property]
    end
  end
end

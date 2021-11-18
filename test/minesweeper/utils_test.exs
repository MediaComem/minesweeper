defmodule Minesweeper.UtilsTest do
  use ExUnit.Case, async: true

  alias Minesweeper.Utils

  defmodule TestServer do
    use GenServer

    @impl true
    def init(:ok), do: {:ok, :state}

    @impl true
    def init(:foo), do: {:stop, :foo}
  end

  test "start a singleton gen server" do
    assert {:ok, pid} = Utils.start_singleton_gen_server(TestServer, :ok)
    assert Utils.start_singleton_gen_server(TestServer, :ok) == {:ok, pid}
  end

  test "fail to start a singleton gen server" do
    assert {:error, :foo} == Utils.start_singleton_gen_server(TestServer, :foo)
  end
end

defmodule Minesweeper.Utils do
  def start_singleton_gen_server(module, id) do
    case GenServer.start_link(module, id, name: {:global, {module, id}}) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, error} -> {:error, error}
    end
  end
end

defmodule Minesweeper.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Minesweeper.Repo,
      # Start the Telemetry supervisor
      MinesweeperWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Minesweeper.PubSub},
      # Start the Endpoint (http/https)
      MinesweeperWeb.Endpoint
      # Start a worker by calling: Minesweeper.Worker.start_link(arg)
      # {Minesweeper.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Minesweeper.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MinesweeperWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

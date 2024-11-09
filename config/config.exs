# This file is responsible for configuring your application and its dependencies
# with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and is restricted to
# this project.

import Config

config :minesweeper,
  ecto_repos: [Minesweeper.Repo]

# Configure the database connection URL.
config :minesweeper, Minesweeper.Repo, url: "ecto://minesweeper@localhost/minesweeper"

# Configure the web endpoint.
config :minesweeper, MinesweeperWeb.Endpoint,
  http: [port: 3000],
  pubsub_server: Minesweeper.PubSub,
  render_errors: [view: MinesweeperWeb.Errors.ErrorsView, accepts: ~w(html json), layout: false],
  server: true,
  url: [
    host: "localhost",
    port: 3000
  ]

# Configures Elixir's Logger.
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix.
config :phoenix, :json_library, Jason

config_dir = Path.dirname(__ENV__.file)

# Import environment specific config. This must remain at the bottom of this
# file so it overrides the configuration defined above.
import_config Path.join(config_dir, "#{Mix.env()}.exs")

local_config_file = Path.join(config_dir, "local.exs")
if File.exists?(local_config_file), do: import_config(local_config_file)

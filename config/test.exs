use Mix.Config

# Configure the database connection.
config :minesweeper, Minesweeper.Repo, pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required, you can enable the
# server option below.
config :minesweeper, MinesweeperWeb.Endpoint, server: false

# Print only warnings and errors during test.
config :logger, level: :warn

# Generate coverage report when re-running tests.
config :mix_test_watch, tasks: ["coveralls.html"]

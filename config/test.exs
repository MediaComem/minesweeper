use Mix.Config

# Configure the database connection.
#
# The MIX_TEST_PARTITION environment variable can be used to provide built-in
# test partitioning in CI environment. Run `mix help test` for more information.
config :minesweeper, Minesweeper.Repo,
  username: "unknow",
  database: "minesweeper-test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required, you can enable the
# server option below.
config :minesweeper, MinesweeperWeb.Endpoint, server: false

# Print only warnings and errors during test.
config :logger, level: :warn

# Generate coverage report when re-running tests.
config :mix_test_watch, tasks: ["coveralls.html"]

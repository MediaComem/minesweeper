use Mix.Config

# Configure the database connection URL (format is
# "ecto://<username>[:<password>]@<host>[:<port>]/<database-name>").
config :minesweeper, Minesweeper.Repo,
  url:
    if(config_env() != :test,
      do: "ecto://minesweeper:changeme@localhost/minesweeper",
      # The MIX_TEST_PARTITION environment variable can be used to provide built-in
      # test partitioning in CI environment. Run `mix help test` for more information.
      else:
        "ecto://minesweeper:changeme@localhost/minesweeper-test#{System.get_env("MIX_TEST_PARTITION")}"
    )

# Configure the web endpoint.
config :minesweeper, MinesweeperWeb.Endpoint,
  # Use `mix phx.gen.secret` to generate a suitable value for the secret key
  # base.
  secret_key_base: "changeme"

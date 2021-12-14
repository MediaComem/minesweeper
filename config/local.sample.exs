import Config

# Configure the database connection URL.
#
# The format is:  "ecto://<username>[:<password>]@<host>[:<port>]/<database-name>"
# For example:    "ecto://minesweeper:mysecretpassword@localhost:5432/minesweeper"
config :minesweeper, Minesweeper.Repo,
  url:
    if(config_env() != :test,
      # Use a different database for development/production and for testing.
      do: "ecto://minesweeper:changeme@localhost/minesweeper",
      else: "ecto://minesweeper:changeme@localhost/minesweeper-test"
    )

# Configure the web endpoint.
config :minesweeper, MinesweeperWeb.Endpoint,
  # Use "mix phx.gen.secret" to generate a suitable value for the secret key
  # base.
  secret_key_base: "changeme"

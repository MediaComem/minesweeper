use Mix.Config

# Configure the database connection URL (format is
# "ecto://<username>[:<password>]@<host>[:<port>]/<database-name>").
config :minesweeper, Minesweeper.Repo, url: "ecto://minesweeper:changeme@localhost/minesweeper"

# Configure the web endpoint.
config :minesweeper, MinesweeperWeb.Endpoint,
  # Use `mix phx.gen.secret` to generate a suitable value for the secret key
  # base.
  secret_key_base: "changeme"

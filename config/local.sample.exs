import Config

# Configure the database connection.
#
# The various connection parameters (host, port, username, password, database
# name) are provided by specifying an URL (see
# https://hexdocs.pm/ecto/Ecto.Repo.html#module-urls for more information).
#
# The format is:  "ecto://<username>[:<password>]@<host>[:<port>]/<database-name>"
# For example:    "ecto://minesweeper:mysecretpassword@localhost:5432/minesweeper"
config :minesweeper, Minesweeper.Repo,
  url:
    if(config_env() != :test,
      # This is the production database URL. You can override it at runtime with
      # the $MINESWEEPER_DATABASE_URL environment variable.
      do: "ecto://minesweeper:changeme@localhost/minesweeper",
      # This is a separate test database URL to avoid overwriting
      # development/production data during tests. You only need to configure
      # this if you want to run the automated tests.
      else: "ecto://minesweeper:changeme@localhost/minesweeper-test"
    )

# Configure the web endpoint.
config :minesweeper, MinesweeperWeb.Endpoint,
  # The secret key base is used as a base to generate secrets for encrypting and
  # signing data. For example, cookies and tokens are signed by default. This
  # should be a long random string.
  #
  # You can override it at runtime with the $MINESWEEPER_SECRET_KEY_BASE
  # environment variable.
  #
  # Run "mix phx.gen.secret" at the root of this repository to generate a
  # suitable value for the secret key base.
  secret_key_base: "changeme"

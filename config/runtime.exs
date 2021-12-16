import Config

# Configure the database connection URL.
config :minesweeper, Minesweeper.Repo, url: Minesweeper.Config.database_url!()

# Configure the web endpoint.
config :minesweeper, MinesweeperWeb.Endpoint,
  http: [port: Minesweeper.Config.port!()],
  secret_key_base: Minesweeper.Config.secret_key_base!(),
  url: Minesweeper.Config.url!()

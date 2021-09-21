defmodule Minesweeper.Repo do
  use Ecto.Repo,
    otp_app: :minesweeper,
    adapter: Ecto.Adapters.Postgres
end

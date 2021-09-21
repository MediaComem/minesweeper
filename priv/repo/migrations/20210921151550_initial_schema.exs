defmodule Minesweeper.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION \"uuid-ossp\";", "DROP EXTENSION \"uuid-ossp\";")
    execute("CREATE TYPE game_state AS ENUM ('ongoing', 'win', 'loss');", "DROP TYPE game_state;")

    create table("games", primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :state, :game_state, default: "ongoing", null: false
      add :data, :map, null: false
      add :version, :integer, default: 0, null: false
      timestamps(inserted_at: :created_at, type: :naive_datetime_usec, null: false)
    end
  end
end

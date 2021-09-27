defmodule Minesweeper.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION \"uuid-ossp\";", "DROP EXTENSION \"uuid-ossp\";")
    execute("CREATE TYPE game_state AS ENUM ('ongoing', 'win', 'loss');", "DROP TYPE game_state;")

    create table("games", primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :state, :game_state, default: "ongoing", null: false
      add :bombs, {:array, :integer}, null: false
      add :version, :integer, default: 0, null: false
      timestamps(inserted_at: :created_at, type: :naive_datetime_usec, null: false)
    end

    create table("moves", primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :position, {:array, :integer}, null: false
      add :game_id, references("games", type: :uuid, on_delete: :delete_all, on_update: :restrict)
      timestamps(inserted_at: :played_at, updated_at: false, type: :naive_datetime_usec, null: false)
    end

    create index(:moves, [:game_id, :played_at])
  end
end

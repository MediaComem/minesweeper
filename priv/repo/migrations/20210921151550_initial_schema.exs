defmodule Minesweeper.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";", "DROP EXTENSION \"uuid-ossp\";")
    execute("CREATE TYPE game_state AS ENUM ('ongoing', 'win', 'loss');", "DROP TYPE game_state;")

    create table("games", primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :width, :integer, null: false
      add :height, :integer, null: false
      add :state, :game_state, null: false
      add :bombs, {:array, {:array, :integer}}, null: false
      add :version, :integer, default: 0, null: false
      timestamps(inserted_at: :created_at, type: :utc_datetime_usec, null: false)
    end

    create table("moves", primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :position, {:array, :integer}, null: false

      add :game_id,
          references("games", type: :uuid, on_delete: :delete_all, on_update: :restrict),
          null: false

      timestamps(
        inserted_at: :played_at,
        updated_at: false,
        type: :utc_datetime_usec,
        null: false
      )
    end

    create constraint(:games, :dimensions_are_valid, check: "width >= 1 AND height >= 1")

    create constraint(:games, :bombs_fit_on_board,
             check: "array_length(bombs, 1) < width * height - 1"
           )

    create index(:moves, [:game_id, :played_at])
  end
end

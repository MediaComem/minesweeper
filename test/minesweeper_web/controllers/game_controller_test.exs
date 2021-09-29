defmodule MinesweeperWeb.GameControllerTest do
  use MinesweeperWeb.ConnCase, async: true

  alias Minesweeper.Game
  alias Minesweeper.Move
  alias Minesweeper.Repo

  import Ecto.Query, only: [from: 2]

  @uuid_regexp ~r/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/

  test "POST /api/games", %{conn: conn, now: now} do
    conn =
      post(conn, "/api/games", width: 30, height: 16, number_of_bombs: 99, first_move: [2, 3])

    body = json_response(conn, 200)

    assert %{
             "id" => id,
             "moves" => [%{"played_at" => played_at_str}],
             "created_at" => created_at_str
           } = body

    assert id =~ @uuid_regexp

    assert {:ok, played_at, 0} = DateTime.from_iso8601(played_at_str)
    assert DateTime.diff(now, played_at, :second) <= 1

    assert {:ok, created_at, 0} = DateTime.from_iso8601(created_at_str)
    assert DateTime.diff(now, created_at, :second) <= 1

    assert body == %{
             "id" => id,
             "width" => 30,
             "height" => 16,
             "bombs" => 99,
             "state" => "ongoing",
             "moves" => [%{"position" => [2, 3], "played_at" => played_at_str}],
             "created_at" => created_at_str
           }

    created_game = from(g in Game, where: g.id == ^id) |> Repo.one()
    assert %Game{bombs: bombs} = created_game

    assert length(bombs) == 99
    assert Enum.uniq(bombs) == bombs

    assert Enum.all?(bombs, fn [col, row] ->
             assert col >= 1
             assert col <= 30
             assert row >= 1
             assert row <= 16
           end)

    assert created_game == %Game{
             __meta__: created_game.__meta__,
             id: id,
             width: 30,
             height: 16,
             state: :ongoing,
             bombs: bombs,
             created_at: created_at,
             updated_at: created_at
           }

    [created_move] = from(m in Move, where: m.game_id == ^id) |> Repo.all()

    assert created_move == %Move{
             __meta__: created_move.__meta__,
             id: created_move.id,
             game_id: id,
             position: [2, 3],
             played_at: played_at
           }
  end
end

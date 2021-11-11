defmodule MinesweeperWeb.GameControllerTest do
  use MinesweeperWeb.ConnCase

  alias Minesweeper.Game
  alias Minesweeper.Move
  alias Minesweeper.Repo

  import Ecto.Query, only: [from: 2]
  import Minesweeper.Factory
  import Minesweeper.TestUtils

  test "POST /api/games to start a game", %{conn: conn, now: now} do
    conn =
      post(conn, "/api/games", width: 30, height: 16, number_of_bombs: 99, first_move: [2, 3])

    body = json_response(conn, 201)

    assert %{
             "id" => id,
             "moves" => [
               %{"uncovered" => uncovered, "played_at" => played_at_str}
             ],
             "created_at" => created_at_str
           } = body

    assert id =~ uuid_regexp()
    assert length(uncovered) >= 1
    assert length(uncovered) <= 99
    assert [2, 3] in Enum.map(uncovered, &List.first/1)

    for [[col, row], bombs_uncovered] <- uncovered do
      assert col >= 1
      assert col <= 30
      assert row >= 1
      assert row <= 16
      assert bombs_uncovered >= 0
      assert bombs_uncovered <= 8
    end

    assert {:ok, played_at, 0} = DateTime.from_iso8601(played_at_str)
    assert DateTime.diff(now, played_at, :second) <= 1

    assert {:ok, created_at, 0} = DateTime.from_iso8601(created_at_str)
    assert DateTime.diff(now, created_at, :second) <= 1

    assert body == %{
             "id" => id,
             "width" => 30,
             "height" => 16,
             "number_of_bombs" => 99,
             "state" => "ongoing",
             "moves" => [
               %{
                 "position" => [2, 3],
                 "uncovered" => uncovered,
                 "played_at" => played_at_str
               }
             ],
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

  test "POST /api/games/:id/moves to play in a game", %{conn: conn, now: now} do
    game = insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]]], returning: [:id])

    conn = post(conn, "/api/games/#{game.id}/moves", position: [1, 1])

    body = json_response(conn, 201)

    assert %{"id" => id, "played_at" => played_at_str} = body
    assert id =~ uuid_regexp()
    assert {:ok, played_at, 0} = DateTime.from_iso8601(played_at_str)
    assert DateTime.diff(now, played_at, :second) <= 1

    assert body == %{
             "id" => id,
             "game_id" => game.id,
             "game" => %{
               "id" => game.id,
               "state" => "ongoing"
             },
             "position" => [1, 1],
             "uncovered" => [[[1, 1], 3]],
             "played_at" => played_at_str
           }

    created_move = from(m in Move, where: m.id == ^id) |> Repo.one()

    assert created_move == %Move{
             __meta__: created_move.__meta__,
             id: id,
             game_id: game.id,
             position: [1, 1],
             played_at: played_at
           }
  end

  test "POST /api/games/:id/moves to win the game", %{conn: conn, now: now} do
    game = insert(:game, [width: 5, height: 5, bombs: [[1, 5], [2, 4], [2, 5]]], returning: [:id])
    insert(:move, game: game, position: [1, 2])

    conn = post(conn, "/api/games/#{game.id}/moves", position: [1, 4])

    body = json_response(conn, 201)

    assert %{"id" => id, "played_at" => played_at_str} = body
    assert id =~ uuid_regexp()
    assert {:ok, played_at, 0} = DateTime.from_iso8601(played_at_str)
    assert DateTime.diff(now, played_at, :second) <= 1

    assert body == %{
             "id" => id,
             "game_id" => game.id,
             "game" => %{
               "id" => game.id,
               "state" => "win",
               "bombs" => [[1, 5], [2, 4], [2, 5]]
             },
             "position" => [1, 4],
             "uncovered" => [[[1, 4], 3]],
             "played_at" => played_at_str
           }

    created_move = from(m in Move, where: m.id == ^id) |> Repo.one()

    assert created_move == %Move{
             __meta__: created_move.__meta__,
             id: id,
             game_id: game.id,
             position: [1, 4],
             played_at: played_at
           }
  end
end

defmodule MinesweeperWeb.GameControllerTest do
  use MinesweeperWeb.ConnCase

  alias Ecto.UUID
  alias Minesweeper.Game
  alias Minesweeper.Move
  alias Minesweeper.Repo

  import Ecto.Query, only: [from: 2]
  import Minesweeper.Factory
  import Minesweeper.TestUtils

  test "POST /api/games starts a game", %{conn: conn, now: now} do
    conn =
      post(conn, "/api/games", width: 30, height: 16, number_of_bombs: 99, first_move: [2, 3])

    body = json_response(conn, 201)
    assert_database_counts(%{Game => 1, Move => 1})

    assert %{
             "id" => id,
             "state" => state,
             "moves" => [
               %{"uncovered" => uncovered, "played_at" => played_at_str}
             ],
             "created_at" => created_at_str
           } = body

    assert id =~ uuid_regexp()
    assert state == "ongoing" || state == "win"
    assert length(uncovered) >= 1
    assert length(uncovered) <= 30 * 16 - 99
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
             "state" => state,
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
    assert %Game{state: game_state, bombs: bombs} = created_game

    assert Atom.to_string(game_state) == state
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
             state: game_state,
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

  test "POST /api/games cannot start a game with invalid data", %{conn: conn} do
    conn = post(conn, "/api/games", height: 0, number_of_bombs: "foo", first_move: [1])

    body = json_response(conn, 422)
    assert_database_counts(%{})

    assert_validation_errors(body, [
      %{"path" => "/width", "message" => "can't be blank"},
      %{"path" => "/height", "message" => "must be greater than or equal to 2"},
      %{"path" => "/number_of_bombs", "message" => "is invalid"},
      %{"path" => "/first_move", "message" => "is not a column and row pair"}
    ])
  end

  test "GET /api/games/:id shows an ongoing game", %{conn: conn} do
    game = insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]]], returning: [:id])
    insert(:move, game: game, position: [1, 1])
    assert_database_counts(%{Game => 1, Move => 1})

    conn = get(conn, "/api/games/#{game.id}")

    body = json_response(conn, 200)
    assert_database_counts(%{Game => 1, Move => 1})

    assert body == %{
             "id" => game.id,
             "width" => 3,
             "height" => 3,
             "number_of_bombs" => length(game.bombs),
             "state" => "ongoing",
             "created_at" => DateTime.to_iso8601(game.created_at),
             "moves" => [
               %{"position" => [1, 1], "uncovered" => [[[1, 1], 3]]}
             ]
           }
  end

  test "GET /api/games/:id shows a lost game", %{conn: conn} do
    game =
      insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]], state: :loss],
        returning: [:id]
      )

    insert(:move, game: game, position: [1, 1])
    insert(:move, game: game, position: [2, 1])

    assert_database_counts(%{Game => 1, Move => 2})

    conn = get(conn, "/api/games/#{game.id}")

    body = json_response(conn, 200)
    assert_database_counts(%{Game => 1, Move => 2})

    assert body == %{
             "id" => game.id,
             "width" => 3,
             "height" => 3,
             "bombs" => [[1, 2], [2, 1], [2, 2]],
             "number_of_bombs" => length(game.bombs),
             "state" => "loss",
             "created_at" => DateTime.to_iso8601(game.created_at),
             "moves" => [
               %{"position" => [1, 1], "uncovered" => [[[1, 1], 3]]},
               %{"position" => [2, 1]}
             ]
           }
  end

  test "GET /api/games/:id shows a won game", %{conn: conn} do
    game = insert(:game, [width: 3, height: 3, bombs: [[1, 1]], state: :win], returning: [:id])
    insert(:move, game: game, position: [2, 1])
    insert(:move, game: game, position: [3, 3])
    assert_database_counts(%{Game => 1, Move => 2})

    conn = get(conn, "/api/games/#{game.id}")

    body = json_response(conn, 200)
    assert_database_counts(%{Game => 1, Move => 2})

    assert body == %{
             "id" => game.id,
             "width" => 3,
             "height" => 3,
             "bombs" => [[1, 1]],
             "number_of_bombs" => length(game.bombs),
             "state" => "win",
             "created_at" => DateTime.to_iso8601(game.created_at),
             "moves" => [
               %{"position" => [2, 1], "uncovered" => [[[2, 1], 1]]},
               %{
                 "position" => [3, 3],
                 "uncovered" => [
                   [[1, 2], 1],
                   [[1, 3], 0],
                   [[2, 2], 1],
                   [[2, 3], 0],
                   [[3, 1], 0],
                   [[3, 2], 0],
                   [[3, 3], 0]
                 ]
               }
             ]
           }
  end

  test "GET /api/games/:id cannot find a game with an invalid ID", %{conn: conn} do
    insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]]], returning: [:id])
    assert_database_counts(%{Game => 1})

    conn = get(conn, "/api/games/foo")

    body = json_response(conn, 404)
    assert_database_counts(%{Game => 1})

    assert body == %{
             "code" => "resource_not_found",
             "resource" => "game"
           }
  end

  test "GET /api/games/:id cannot show a non-existing game", %{conn: conn} do
    insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]]], returning: [:id])
    assert_database_counts(%{Game => 1})

    conn = get(conn, "/api/games/#{UUID.generate()}")

    body = json_response(conn, 404)
    assert_database_counts(%{Game => 1})

    assert body == %{
             "code" => "resource_not_found",
             "resource" => "game"
           }
  end

  test "POST /api/games/:id/moves plays a move in a game", %{conn: conn, now: now} do
    game = insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]]], returning: [:id])
    assert_database_counts(%{Game => 1})

    conn = post(conn, "/api/games/#{game.id}/moves", position: [1, 1])

    body = json_response(conn, 201)
    assert_database_counts(%{Game => 1, Move => 1})

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

  test "POST /api/games/:id/moves can win the game", %{conn: conn, now: now} do
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

  test "POST /api/games/:id/moves cannot play a move with invalid data", %{conn: conn} do
    game = insert(:game, [width: 3, height: 3, bombs: [[1, 2], [2, 1], [2, 2]]], returning: [:id])
    assert_database_counts(%{Game => 1})

    conn = post(conn, "/api/games/#{game.id}/moves", position: [0, 1])

    body = json_response(conn, 422)
    assert_database_counts(%{Game => 1})

    assert_validation_errors(body, [
      %{"path" => "/position", "message" => "is not a column and row pair"}
    ])
  end

  test "POST /api/games/:id/moves cannot play a move in an non-existent game", %{conn: conn} do
    assert_database_counts(%{})

    conn = post(conn, "/api/games/#{UUID.generate()}/moves", position: [1, 1])

    body = json_response(conn, 404)
    assert_database_counts(%{})

    assert body == %{
             "code" => "resource_not_found",
             "resource" => "game"
           }
  end

  test "POST /api/games/:id/moves cannot play a move in a completed game", %{conn: conn} do
    game = insert(:game, [width: 3, height: 3, bombs: [[1, 1]], state: :loss], returning: [:id])
    insert(:move, game: game, position: [1, 1])
    assert_database_counts(%{Game => 1, Move => 1})

    conn = post(conn, "/api/games/#{game.id}/moves", position: [1, 1])

    body = json_response(conn, 422)
    assert_database_counts(%{Game => 1, Move => 1})

    assert body == %{
             "code" => "game_done",
             "state" => "loss"
           }
  end
end

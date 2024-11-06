defmodule Minesweeper.GameServerTest do
  use Minesweeper.DataCase

  import Minesweeper.Factory
  import Minesweeper.TestUtils

  alias Ecto.UUID
  alias Minesweeper.Game
  alias Minesweeper.GameServer
  alias Minesweeper.Move

  test "play in an ongoing game", %{now: now} do
    bombs = [[1, 2], [2, 1], [2, 2]]

    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs],
        returning: [:id]
      )

    start_link_supervised!({GameServer, game.id})

    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [1, 1])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: new_move.id,
             game: updated_game,
             game_id: game.id,
             position: [1, 1],
             uncovered: [{[1, 1], 3}],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 3,
             height: 3,
             state: :ongoing,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }
  end

  test "win the game", %{now: now} do
    bombs = [[1, 2]]

    # ┌───┐
    # │   │
    # │*  │
    # │   │
    # └───┘
    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs],
        returning: [:id]
      )

    # ┌───┐
    # │x  │ x == 1
    # │*  │ y == 1
    # │y  │
    # └───┘
    insert(:move, game: game, position: [1, 1])
    insert(:move, game: game, position: [1, 3])

    start_link_supervised!({GameServer, game.id})

    # ┌───┐
    # │x1z│ x == 1
    # │*10│ y == 1
    # │y10│ z == 0
    # └───┘
    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [3, 1])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: id,
             game: updated_game,
             game_id: updated_game.id,
             position: [3, 1],
             uncovered: [
               {[2, 1], 1},
               {[2, 2], 1},
               {[2, 3], 1},
               {[3, 1], 0},
               {[3, 2], 0},
               {[3, 3], 0}
             ],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 3,
             height: 3,
             state: :win,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }
  end

  test "lose the game", %{now: now} do
    bombs = [[1, 2]]

    # ┌───┐
    # │   │
    # │*  │
    # │   │
    # └───┘
    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs],
        returning: [:id]
      )

    # ┌───┐
    # │x  │ x = 1
    # │*  │
    # │   │
    # └───┘
    insert(:move, game: game, position: [1, 1])

    start_link_supervised!({GameServer, game.id})

    # ┌───┐
    # │x  │ x = 1
    # │y  │ y = *
    # │   │
    # └───┘
    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [1, 2])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: id,
             game: updated_game,
             game_id: updated_game.id,
             position: [1, 2],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 3,
             height: 3,
             state: :loss,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }
  end

  test "win a complex game in 1 move after 1 stored move", %{now: now} do
    bombs = [[1, 5], [2, 4], [2, 5]]

    # ┌─────┐
    # │     │
    # │     │
    # │     │
    # │ *   │
    # │**   │
    # └─────┘
    game =
      insert(
        :game,
        [width: 5, height: 5, bombs: bombs],
        returning: [:id]
      )

    # ┌─────┐
    # │00000│ a = 0
    # │a0000│
    # │11100│
    # │ *200│
    # │**200│
    # └─────┘
    insert(:move, game: game, position: [1, 2])

    start_link_supervised!({GameServer, game.id})

    # ┌─────┐
    # │00000│ b = 3
    # │a0000│
    # │11100│
    # │b*200│
    # │**200│
    # └─────┘
    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [1, 4])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: id,
             game: updated_game,
             game_id: updated_game.id,
             position: [1, 4],
             uncovered: [
               {[1, 4], 3}
             ],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 5,
             height: 5,
             state: :win,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }
  end

  test "win a complex game in 2 moves", %{now: now} do
    bombs = [[1, 5], [2, 4], [2, 5]]

    # ┌─────┐
    # │     │
    # │     │
    # │     │
    # │ *   │
    # │**   │
    # └─────┘
    game =
      insert(
        :game,
        [width: 5, height: 5, bombs: bombs],
        returning: [:id]
      )

    start_link_supervised!({GameServer, game.id})

    # ┌─────┐
    # │00000│ a = 0
    # │a0000│
    # │11100│
    # │ *200│
    # │**200│
    # └─────┘
    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [1, 2])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: id,
             game: updated_game,
             game_id: updated_game.id,
             position: [1, 2],
             uncovered: [
               {[1, 1], 0},
               {[1, 2], 0},
               {[1, 3], 1},
               {[2, 1], 0},
               {[2, 2], 0},
               {[2, 3], 1},
               {[3, 1], 0},
               {[3, 2], 0},
               {[3, 3], 1},
               {[3, 4], 2},
               {[3, 5], 2},
               {[4, 1], 0},
               {[4, 2], 0},
               {[4, 3], 0},
               {[4, 4], 0},
               {[4, 5], 0},
               {[5, 1], 0},
               {[5, 2], 0},
               {[5, 3], 0},
               {[5, 4], 0},
               {[5, 5], 0}
             ],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 5,
             height: 5,
             state: :ongoing,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }

    # ┌─────┐
    # │00000│ b = 3
    # │a0000│
    # │11100│
    # │b*200│
    # │**200│
    # └─────┘
    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [1, 4])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: id,
             game: updated_game,
             game_id: updated_game.id,
             position: [1, 4],
             uncovered: [
               {[1, 4], 3}
             ],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 5,
             height: 5,
             state: :win,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }
  end

  test "win a complex game in 1 move after 4 stored moves", %{now: now} do
    bombs = [[1, 3], [3, 5], [5, 3]]

    # ┌─────┐
    # │     │
    # │     │
    # │*   *│
    # │     │
    # │  *  │
    # └─────┘
    game =
      insert(
        :game,
        [width: 5, height: 5, bombs: bombs],
        returning: [:id]
      )

    # ┌─────┐
    # │     │ a = 1
    # │a    │
    # │*   *│
    # │     │
    # │  *  │
    # └─────┘
    insert(:move, game: game, position: [1, 2])

    # ┌─────┐
    # │00000│ a = 1
    # │a1b11│ b = 0
    # │*101*│
    # │ 212 │
    # │  *  │
    # └─────┘
    insert(:move, game: game, position: [3, 2])

    # ┌─────┐
    # │00000│ a = 1
    # │a1b11│ b = 0
    # │*101*│ c = 1
    # │1212 │
    # │c1*  │
    # └─────┘
    insert(:move, game: game, position: [1, 5])

    # ┌─────┐
    # │00000│ a = 1
    # │a1b11│ b = 0
    # │*101*│ c = 1
    # │1212d│ d = 1
    # │c1*  │
    # └─────┘
    insert(:move, game: game, position: [5, 4])

    start_link_supervised!({GameServer, game.id})

    # ┌─────┐
    # │00000│ e = 0
    # │11011│
    # │*101*│
    # │12121│
    # │c1*1e│
    # └─────┘
    assert {:ok, %Move{id: id, game: updated_game, played_at: played_at} = new_move} =
             GameServer.play(game.id, [5, 5])

    assert id =~ uuid_regexp()
    assert DateTime.diff(now, played_at, :second) <= 1

    assert new_move == %Move{
             __meta__: new_move.__meta__,
             id: id,
             game: updated_game,
             game_id: updated_game.id,
             position: [5, 5],
             uncovered: [
               {[4, 5], 1},
               {[5, 5], 0}
             ],
             played_at: played_at
           }

    assert updated_game == %Game{
             __meta__: updated_game.__meta__,
             id: game.id,
             width: 5,
             height: 5,
             state: :win,
             bombs: bombs,
             created_at: game.created_at,
             updated_at: updated_game.updated_at
           }
  end

  test "start an existing game server" do
    bombs = [[1, 2], [2, 1], [2, 2]]

    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs],
        returning: [:id]
      )

    insert(:move, game: game, position: [1, 1])

    assert pid = start_link_supervised!({GameServer, game.id})
    assert GameServer.start_link(game.id) == {:ok, pid}
  end

  @tag capture_log: true
  test "cannot play in a non-existent game", _ do
    Process.flag(:trap_exit, true)
    assert {:ok, _} = GameServer.start_link(UUID.generate())
    assert_receive {:EXIT, _, :game_not_found}
  end

  @tag capture_log: true
  test "cannot play in a lost game", _ do
    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: [[1, 1]], state: :loss],
        returning: [:id]
      )

    insert(:move, game: game, position: [1, 1])

    Process.flag(:trap_exit, true)
    assert {:ok, _} = GameServer.start_link(game.id)
    assert_receive {:EXIT, _, {:game_done, :loss}}
  end

  @tag capture_log: true
  test "cannot play in a won game", _ do
    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: [[1, 1]], state: :win],
        returning: [:id]
      )

    insert(:move, game: game, position: [3, 3])

    Process.flag(:trap_exit, true)
    assert {:ok, _} = GameServer.start_link(game.id)
    assert_receive {:EXIT, _, {:game_done, :win}}
  end

  test "cannot play outside the board" do
    bombs = [[1, 2], [2, 1], [2, 2]]

    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs],
        returning: [:id]
      )

    insert(:move, game: game, position: [1, 1])

    assert {:ok, _} = GameServer.start_link(game.id)

    assert {:error, {:game_error, :position_outside_board}} = GameServer.play(game.id, [4, 3])
  end
end

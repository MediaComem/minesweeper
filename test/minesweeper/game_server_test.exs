defmodule Minesweeper.GameServerTest do
  use Minesweeper.DataCase

  import Minesweeper.Factory
  import Minesweeper.TestUtils

  alias Minesweeper.Game
  alias Minesweeper.GameServer
  alias Minesweeper.Move

  test "play in an ongoing game", %{now: now} do
    bombs = [[1, 2], [2, 1], [2, 2]]

    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs, moves: []],
        returning: [:id]
      )

    assert :ok = GameServer.start_link(game.id)

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
        [width: 3, height: 3, bombs: bombs, moves: []],
        returning: [:id]
      )

    # ┌───┐
    # │x  │ x == 1
    # │*  │ y == 1
    # │y  │
    # └───┘
    insert(:move, game: game, position: [1, 1])
    insert(:move, game: game, position: [1, 3])

    assert :ok = GameServer.start_link(game.id)

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

    game =
      insert(
        :game,
        [width: 3, height: 3, bombs: bombs, moves: []],
        returning: [:id]
      )

    insert(:move, game: game, position: [1, 1])

    assert :ok = GameServer.start_link(game.id)

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
end
